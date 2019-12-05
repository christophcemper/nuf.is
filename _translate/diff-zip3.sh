

#
# 1. create feature branch feature/translate-YYYYMMDD
# 2. edit those files that need translation (EN+DE)
# 3. from the feature branch
# 4. run with sh ....  translate-YYYYMMDD
# 5. e.g. sh diff-zip3.sh translate-20190726
#


if [ $# -eq 0 ]
  then
    echo "No arguments supplied."
    echo "Usage: diff-zip3.sh <translation-tag-name without feature branch>"
    echo "Options:"
    echo " -v | --verbose"
    exit
fi



# get modifiers
for i in "$@"
do
case $i in
    -d=*|--dir=*)
    hotfix_dir="${i#*=}"
    shift # past argument=value
    ;;
    -v|--verbose)
    VERBOSE="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done



if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"

    hotfix_tag=$1
else
    exit
fi


if [ $VERBOSE ]; then

  echo "VERBOSE MODE ON"
  echo "working for tag  = ${hotfix_tag}"
  echo "working in dir   = ${hotfix_dir}"
  echo "zipping to dir   = ${hotfix_zipdir}"
  echo "PATHSTARTOFFSET  = ${PATHSTARTOFFSET}"

###
fi


##7z a test5.zip  "./src/lrt-de/FAQ/faq-konkurrenzanalyse.md" "./src/lrt-en/02 Concepts/Link Analysis Concepts/NoFollow Link Evaluation.assets/DomainDTOXRISK-NoFollow-Eval-Classic.png"



function myLog () {
    if [ $VERBOSE ]; then
      str="$*"
      echo " "
      echo $str
      echo " "
    fi
}



function promptLog () {
    if [ $VERBOSE ]; then

      nowstr=`date +'%Y-%m-%d--%H-%M-%S'`
      myLog "---"
      read -n 1 -p "[ ${nowstr} ] ${1} -  Proceed?"
      myLog "---"
      if [ $REPLY == 'n' ]; then
        echo "need to exit"
        exit
      fi
    fi
}




function createZip () {

  #cwd=$(pwd)
  #echo $cwd
  dstr=`date +'%Y-%m-%d--%H-%M-%S'`

  filename2=$filename1-$dstr

  cwd=$filename2

  mkdir out
  cd out

  mkdir $cwd

  ##git diff --name-only master -- ../src/lrt-en

  promptLog "looking good?"

  myLog "git diff --name-only $translation_needed_branch  | sed 's/.*/"..\/..\/&"/' | sed 's/^\/\(.*\)/\1/' > ziplistfile.txt"

  git diff --name-only $translation_needed_branch  | sed 's/.*/"..\/..\/&"/' | sed 's/^\/\(.*\)/\1/' > ziplistfile.txt

  promptLog "looking good?"

  myLog "git diff --name-only $translation_needed_branch | sed 's/.*/..\/..\/&/' | sed 's/^\/\(.*\)/\1/' > tarlistfile.txt"

  git diff --name-only $translation_needed_branch | sed 's/.*/..\/..\/&/' | sed 's/^\/\(.*\)/\1/' > tarlistfile.txt

  #echo for tar
  #echo -e $(git diff --name-only master $translation_needed_branch | sed 's/.*/ "..\/&"/' | sed 's/^\/\(.*\)/\1/'  )

  promptLog "looking good?"

  echo tar -cvf $filename2.tar  -T tarlistfile.txt
  tar -cvf $filename2.tar  -T tarlistfile.txt

  ##echo tar -cf $filename2.tar  -T tarlistfile.txt
  ##tar -cf $filename2.tar  -T tarlistfile.txt


  promptLog "looking good?"

  echo noch unpack again here
  myLog "tar -xvf $filename2.tar --directory=$cwd"

  tar -xvf $filename2.tar --directory=$cwd

  promptLog "looking good?"

  echo now zip the whole thing

  myLog "7z a -tzip $filename2.zip $cwd$filter"

  7z a -tzip $filename2.zip $cwd$filter

  promptLog "looking good?"


  pwd


# read -n 1 -p "2.Done reading the logs?" confirmation

  ## cleanup
  rm tarlistfile.txt
  rm ziplistfile.txt
  rm $filename2.tar
  rm -rfd $cwd

  cd ..

  ###7z a test5.zip

}


#translation_needed_branch="feature/translate-20190726"

translation_needed_branch="feature/"$hotfix_tag


filename1=$hotfix_tag
filter="/src"
createZip

filename1=$hotfix_tag"-en-only"
filter="/src/lrt-en"
createZip
