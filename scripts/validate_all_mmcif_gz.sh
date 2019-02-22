#!/bin/bash

source ./scripts/env.sh

if [ $has_cifcheck_command = "false" ] ; then

 echo "CifCheck: command not found..."
 echo "Please install MMCIF Dictionary Suite (http://sw-tools.pdb.org/)."
 exit 1

fi

MMCIF_DIR=
CHK_SUM_DIR=chk_sum_mmcif_valid
DELETE=true

ARGV=`getopt --long -o "d:r" "$@"`
eval set -- "$ARGV"
while true ; do
 case "$1" in
 -d)
  MMCIF_DIR=$2
  shift
 ;;
 -r)
  DELETE=false
 ;;
 *)
  break
 ;;
 esac
 shift
done

if [ ! -z $MMCIF_DIR ] ; then

 total=`find $MMCIF_DIR -mindepth 2 -name '*.cif.gz' | wc -l`

 if [ $total != 0 ] ; then

  mkdir -p $CHK_SUM_DIR

  for dicfile in $pdbx_validation_dic $pdbx_validation_odb $pdbx_validation_sdb ; do

   if [ ! -e $MMCIF_DIR/$dicfile ] ; then
    ( cd $MMCIF_DIR; ln -s ../schema/$dicfile . )
   fi

  done

  echo mmCIF syntax validation: *.cif.gz documents in $MMCIF_DIR...

  cif_file_list=check_${MMCIF_DIR,,}_cif_gz_file_list
  dict_sdb=`readlink -f $MMCIF_DIR/$pdbx_validation_sdb`

  find $MMCIF_DIR -name "*.log" -exec rm {} +

  find $MMCIF_DIR -mindepth 2 -name '*.cif.gz' > $cif_file_list

  for proc_id in `seq 1 $MAXPROCS` ; do

   if [ $DELETE = "true" ] ; then
    ./scripts/validate_all_mmcif_gz_worker.sh -c $CHK_SUM_DIR -s $dict_sdb -l $cif_file_list -n $proc_id"of"$MAXPROCS -r &
   else
    ./scripts/validate_all_mmcif_gz_worker.sh -c $CHK_SUM_DIR -s $dict_sdb -l $cif_file_list -n $proc_id"of"$MAXPROCS &
   fi

  done

  if [ $? != 0 ] ; then

   echo $0 aborted.
   exit 1

  fi

  wait

  echo

  rm -f $cif_file_list

  for dicfile in $pdbx_validation_dic $pdbx_validation_odb $pdbx_validation_sdb ; do

   if [ -e $MMCIF_DIR/$dicfile ] ; then
    rm -f $MMCIF_DIR/$dicfile
   fi

  done

  echo Done.

 fi

fi

