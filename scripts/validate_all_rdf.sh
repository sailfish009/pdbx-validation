#!/bin/bash

source ./scripts/env.sh

if [ $has_rapper_command = "false" ] ; then

 echo "rapper: command not found..."
 echo "Please install Raptor RDF Syntax Library (http://librdf.org/raptor/)."
 exit 1

fi

RDF_DIR=
CHK_SUM_DIR=chk_sum_rdf_valid
DELETE=false

ARGV=`getopt --long -o "d:r" "$@"`
eval set -- "$ARGV"
while true ; do
 case "$1" in
 -d)
  RDF_DIR=$2
  shift
 ;;
 -r)
  DELETE=true
 ;;
 *)
  break
 ;;
 esac
 shift
done

if [ ! -z $RDF_DIR ] ; then

 find $RDF_DIR -maxdepth 1 -name '*.rdf' -size 0 -exec rm {} +

 total=`find $RDF_DIR -maxdepth 1 -name '*.rdf' | wc -l`

 if [ $total != 0 ] ; then

  mkdir -p $CHK_SUM_DIR

  echo RDF syntax validation: *.rdf documents in $RDF_DIR...

  rdf_file_list=check_${RDF_DIR,,}_rdf_file_list

  find $RDF_DIR -name "*.err" -exec rm {} +

  find $RDF_DIR -maxdepth 1 -name '*.rdf' > $rdf_file_list

  for proc_id in `seq 1 $MAXPROCS` ; do

   if [ $DELETE = "true" ] ; then
    ./scripts/validate_all_rdf_worker.sh -c $CHK_SUM_DIR -l $rdf_file_list -n $proc_id"of"$MAXPROCS -r &
   else
    ./scripts/validate_all_rdf_worker.sh -c $CHK_SUM_DIR -l $rdf_file_list -n $proc_id"of"$MAXPROCS &
   fi

  done

  if [ $? != 0 ] ; then

   echo $0 aborted.
   exit 1

  fi

  wait

  echo

  rm -f $rdf_file_list

  red='\e[0;31m'
  normal='\e[0m'

  errs=`find $RDF_DIR -name "*.log" | wc -l`

  if [ $errs != 0 ] ; then

   echo -e "${red}$errs errors were detected. Please check the log files for more details.${normal}"
   exit 1

  fi

  echo Done.

 fi

fi

