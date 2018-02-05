#!/bin/bash

MAXPROCS=`cat /proc/cpuinfo 2> /dev/null | grep 'cpu cores' | wc -l`

if [ $MAXPROCS = 0 ] ; then
 MAXPROCS=1
fi

SAXON=extlibs/saxon9he.jar

if [ ! -e $SAXON ] ; then
 ./scripts/update_extlibs.sh
fi

PDBX_VALIDATION_XSD=schema/pdbx-validation-v0.xsd

if [ ! -e $PDBX_VALIDATION_XSD ] ; then
 (cd schema; ./update_schema.sh)
fi

PDBXV2PDBMLV2RDF_XSL=stylesheet/pdbxv2pdbmlv2rdf.xsl
PDBXV2PDBMLV2RDF_XSL_ERR=pdbxv2pdbmlv2rdf.err

PDBMLV2RDF_XSL=stylesheet/pdbmlv2rdf.xsl

if [ ! -e $PDBMLV2RDF_XSL ] ; then

 java -jar $SAXON -s:$PDBX_VALIDATION_XSD -xsl:$PDBXV2PDBMLV2RDF_XSL -o:$PDBMLV2RDF_XSL 2> $PDBXV2PDBMLV2RDF_XSL_ERR

 if [ $? = 0 ] ; then
  rm -f $PDBXV2PDBMLV2RDF_XSL_ERR
 else
  cat $PDBXV2PDBMLV2RDF_XSL_ERR
  exit 1
 fi

 echo
 echo Generated: $PDBMLV2RDF_XSL

fi

PDBML_VALID=pdbml-validation

if [ ! -d $PDBML_VALID ] ; then
 ./scripts/merge_pdbml_info.sh
fi

RDF_VALID=rdf-validation

mkdir -p $RDF_VALID

echo
echo Translating PDBML-validation to wwPDB/RDF-validation...

pdbml_file_list=pdbml_file_list

find $PDBML_VALID -name '*.xml' > $pdbml_file_list

for proc_id in `seq 1 $MAXPROCS` ; do

 ./scripts/translate_to_rdf_worker.sh -d $RDF_VALID -l $pdbml_file_list -n $proc_id"of"$MAXPROCS $VALID_OPT &

done

if [ $? != 0 ] ; then
 echo "$0 aborted."
 exit 1
fi

wait

echo

rm -f $pdbml_file_list

echo $RDF_VALID is update.
