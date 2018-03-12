#!/bin/bash

source ./scripts/env.sh

if [ ! -e $SAXON ] || [ ! -e $XSD2PGSCHEMA ] ; then
 ./scripts/update_extlibs.sh
fi

if [ ! -e $PDBX_VALIDATION_XSD ] ; then
 ( cd schema; ./update_schema.sh )
fi

if [ ! -e $EXT_PDBML_XSL ] ; then

 java -jar $SAXON -s:$PDBX_VALIDATION_XSD -xsl:$XSD2EXT_PDBML_XSL -o:$EXT_PDBML_XSL

 if [ $? = 0 ] ; then
  echo Generated: $EXT_PDBML_XSL
 else
  echo aborted.
  exit 1
 fi

fi

if [ ! -e $MERGE_PDBML_INFO_XSL ] ; then

 java -jar $SAXON -s:$PDBX_VALIDATION_XSD -xsl:$XSD2MERGE_PDBML_INFO_XSL -o:$MERGE_PDBML_INFO_XSL

 if [ $? = 0 ] ; then
  echo Generated: $MERGE_PDBML_INFO_XSL
 else
  echo aborted.
  exit 1
 fi

fi

if [ ! -e $PDBMLV2RDF_XSL ] ; then

 java -jar $SAXON -s:$PDBX_VALIDATION_XSD -xsl:$PDBXV2PDBMLV2RDF_XSL -o:$PDBMLV2RDF_XSL

 if [ $? = 0 ] ; then
  echo Generated: $PDBMLV2RDF_XSL
 else
  echo aborted.
  exit 1
 fi

fi

WORK_DIR=test

for arg ; do

 pdbid=${arg,,}

 if [[ $pdbid =~ [0-9][0-9a-z]{3} ]] ; then

   pdbml_file=$WORK_DIR/pdbml/$pdbid-noatom.xml
   info_file=$WORK_DIR/validation_info/$pdbid"_validation.xml"

   if [ ! -e $pdbml_file ] ; then

    wget ftp://ftp.wwpdb.org/pub/pdb/data/structures/all/XML-noatom/$pdbid-noatom.xml.gz -P $WORK_DIR/pdbml; gunzip $pdbml_file.gz

   fi

   if [ ! -e $info_file ] ; then

    wget ftp://ftp.wwpdb.org/pub/pdb/validation_reports/${pdbid:1:2}/$pdbid/$pdbid"_validation.xml.gz" -P $WORK_DIR/validation_info; gunzip $info_file.gz

   fi

 fi

done

mkdir -p $WORK_DIR/$PDBML_EXT
mkdir -p $WORK_DIR/$VALID_INFO_ALT
mkdir -p $WORK_DIR/$XML_VALID
mkdir -p $WORK_DIR/$RDF_VALID

for pdbml_file in $WORK_DIR/pdbml/*.xml ; do

 pdbid=`basename $pdbml_file -noatom.xml`

 exptl_method=`java -jar $SAXON -s:$pdbml_file -xsl:stylesheet/exptl_method.xsl`

 echo
 echo Processing PDB ID: ${pdbid^^}, "Exptl. method: "$exptl_method" ..."

 pdbml_ext_file=$WORK_DIR/$PDBML_EXT/$pdbid-noatom-ext.xml
 info_file=../$WORK_DIR/validation_info/$pdbid"_validation.xml"

 java -jar $SAXON -s:$pdbml_file -xsl:$EXT_PDBML_XSL -o:$pdbml_ext_file info_file=$info_file

 if [ $? = 0 ] ; then
  echo " extracted: "$pdbml_ext_file
 else
  echo aborted.
  exit 1
 fi

 java -classpath $XSD2PGSCHEMA xmlvalidator --xsd $PDBX_VALIDATION_XSD --xml $pdbml_ext_file > /dev/null

 if [ $? != 0 ] ; then
  echo aborted.
  exit 1
 else
  echo " validated: "$pdbml_ext_file
 fi

 info_file=$WORK_DIR/validation_info/$pdbid"_validation.xml"
 info_alt_file=$WORK_DIR/$VALID_INFO_ALT/$pdbid-validation-alt.xml
 pdbml_ext_file=../$pdbml_ext_file # add relative path (../) from directory contains target styleseet

 java -jar $SAXON -s:$info_file -xsl:$EXT_INFO_XSL -o:$info_alt_file pdbml_ext_file=$pdbml_ext_file

 if [ $? = 0 ] ; then
  echo " extracted: "$info_alt_file
 else
  echo aborted.
  exit 1
 fi

 java -classpath $XSD2PGSCHEMA xmlvalidator --xsd $PDBX_VALIDATION_XSD --xml $info_alt_file > /dev/null

 if [ $? != 0 ] ; then
  echo aborted.
  exit 1
 else
  echo " validated: "$info_alt_file
 fi

 pdbml_ext_file=$WORK_DIR/$PDBML_EXT/$pdbid-noatom-ext.xml
 info_alt_file=../$info_alt_file # add relative path (../) from directory contains target stylesheet
 pdbml_valid_file=$WORK_DIR/$XML_VALID/$pdbid-validation-full.xml

 java -jar $SAXON -s:$pdbml_ext_file -xsl:$MERGE_PDBML_INFO_XSL -o:$pdbml_valid_file info_alt_file=$info_alt_file

 if [ $? = 0 ] ; then
  echo " merged   : "$pdbml_valid_file
 else
  echo aborted.
  exit 1
 fi

 java -classpath $XSD2PGSCHEMA xmlvalidator --xsd $PDBX_VALIDATION_XSD --xml $pdbml_valid_file > /dev/null

 if [ $? != 0 ] ; then
  echo aborted.
  exit 1
 else
  echo " validated: "$pdbml_valid_file
 fi

 rdf_valid_file=$WORK_DIR/$RDF_VALID/$pdbid-validation.rdf

 java -jar $SAXON -s:$pdbml_valid_file -xsl:$PDBMLV2RDF_XSL -o:$rdf_valid_file

 if [ $? = 0 ] ; then
  echo " generated: "$rdf_valid_file
 else
  echo aborted.
  exit 1
 fi

done

echo
echo Done.

