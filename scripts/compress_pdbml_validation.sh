#!/bin/bash

DB_NAME="PDBML-validation"

PDBML_VALID=pdbml-validation
PDBML_VALID_GZ=XML-validation

if [ ! -d $PDBML_VALID ] ; then
 ./scripts/merge_pdbml_info.sh
fi

echo
echo Compressing PDBML-validation...

mkdir -p $PDBML_VALID_GZ

last=`find $PDBML_VALID_GZ/* -name '*.xml.gz' | wc -l`
total=`find $PDBML_VALID -name '*.xml' | wc -l`

if [ $total != $last ] ; then

 pdbml_file_list=pdbml_file_list

 find $PDBML_VALID -name '*.xml' > $pdbml_file_list

 while read xml_file
 do

  pdb_id=`basename $xml_file -validation-full.xml`
  div_dir=$PDBML_VALID_GZ/${pdb_id:1:2}

  mkdir -p $div_dir

  cp -f $xml_file $div_dir
  gzip $div_dir/$pdb_id-validation-full.xml

 done < $pdbml_file_list

 rm -f $pdbml_file_list

fi

echo $DB_NAME" ("$PDBML_VALID_GZ") is up-to-date."

