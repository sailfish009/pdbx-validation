#!/bin/bash

MAXPROCS=`cat /proc/cpuinfo 2> /dev/null | grep 'cpu cores' | wc -l`

if [ $MAXPROCS = 0 ] ; then
 MAXPROCS=1
fi

VALIDATE_OPT=

ARGV=`getopt --long -o "v" "$@"`
eval set -- "$ARGV"
while true ; do
 case "$1" in
 -v)
  VALIDATE_OPT=$1
 ;;
 *)
  break
 ;;
 esac
 shift
done

SAXON=extlibs/saxon9he.jar
XSD2PGSCHEMA=extlibs/xsd2pgschema.jar

if [ ! -e $SAXON ] || [ ! -e $XSD2PGSCHEMA ] ; then
 ./scripts/update_extlibs.sh
fi

VALID_INFO_EXT=validation_info_ext

mkdir -p $VALID_INFO_EXT

VALID_INFO_DIR=validation_info

if [ ! -d $VALID_INFO_DIR ] ; then
 ./scripts/update_validation.sh
fi

PDBML_EXT_DIR=pdbml_ext

if [ ! -d $PDBML_EXT_DIR ] ; then
 ./scripts/extract_pdbml.sh
fi

echo
echo Extracting wwPDB Validation Information...

info_file_list=info_file_list

find $VALID_INFO_DIR -name '*.xml' > $info_file_list

for proc_id in `seq 1 $MAXPROCS` ; do

 ./scripts/extract_info_worker.sh -d $VALID_INFO_EXT -e $PDBML_EXT_DIR -l $info_file_list -n $proc_id"of"$MAXPROCS $VALIDATE_OPT &

done

if [ $? != 0 ] ; then
 echo "$0 aborted."
 exit 1
fi

wait

echo

rm -f $info_file_list

echo $VALID_INFO_EXT is update.

