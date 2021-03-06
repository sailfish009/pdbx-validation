#!/bin/bash

source ./scripts/env.sh

if [ $has_xml2mmcif_command = "false" ] ; then

 echo "xml2mmcif: command not found..."
 echo "Please install PDBML2MMCIF (https://sw-tools.rcsb.org/apps/PDBML2CIF/index.html) to generate mmCIF version of wwPDB validation reports."

fi

VALID_OPT=

ARGV=`getopt --long -o "v" "$@"`
eval set -- "$ARGV"
while true ; do
 case "$1" in
 -v)
  VALID_OPT=$1
 ;;
 *)
  break
 ;;
 esac
 shift
done

./scripts/update_pdbml.sh || exit $?

./scripts/update_validation.sh || exit $?

huge_number=100000

total=`ls $PDBML_EXT 2> /dev/null | wc -l`

ext_pdbml_exit_code=0
ext_info_exit_code=0

if [ -d $PDBML_EXT ] && [ $total -gt $huge_number ] ; then

 ./scripts/extract_pdbml.sh $VALID_OPT
 ext_pdbml_exit_code=$?

else

 ./scripts/extract_pdbml.sh
 ext_pdbml_exit_code=$?

 if [ ! -z $VALID_OPT ] ; then
  ./scripts/validate_all_xml.sh -d $PDBML_EXT
 fi

fi

total=`ls $VALID_INFO_ALT 2> /dev/null | wc -l`

if [ -d $VALID_INFO_ALT ] && [ $total -gt $huge_number ] ; then

 ./scripts/extract_info.sh $VALID_OPT
 ext_info_exit_code=$?

else

 ./scripts/extract_info.sh
 ext_info_exit_code=$?

 if [ ! -z $VALID_OPT ] ; then
  ./scripts/validate_all_xml.sh -d $VALID_INFO_ALT
 fi

fi

xml_total=`ls $XML_VALID 2> /dev/null | wc -l`
rdf_total=`ls $RDF_VALID 2> /dev/null | wc -l`

if [ $ext_pdbml_exit_code = 0 ] || [ $ext_info_exit_code = 0 ] || [ $xml_total -le $huge_number ] || [ $rdf_total -le $huge_number ] ; then

 if [ -d $XML_VALID ] && [ $xml_total -gt $huge_number ] ; then

  ./scripts/merge_pdbml_info.sh -v

 else

  ./scripts/merge_pdbml_info.sh
  ./scripts/validate_all_xml.sh -d $XML_VALID

 fi

 ./scripts/translate_to_rdf.sh

 if [ $has_xml2mmcif_command != "false" ] ; then
  ./scripts/translate_to_mmcif.sh
 fi

# Deprecated: update_pdbml.sh has already removed.
# ./scripts/sync_delete_with_pdbml.sh

# Deprecated: update_validation.sh has already removed.
# ./scripts/sync_delete_with_info.sh

 ./scripts/compress_pdbml_validation.sh
 ./scripts/compress_rdf_validation.sh

 if [ $has_xml2mmcif_command != "false" ] ; then
  ./scripts/compress_mmcif_validation.sh
 fi

 ./scripts/translate_to_rdf_alt.sh

 if [ $has_xml2mmcif_command != "false" ] ; then
  ./scripts/translate_to_mmcif_alt.sh
 fi

 ./scripts/compress_pdbml_validation_alt.sh
 ./scripts/compress_rdf_validation_alt.sh

 if [ $has_xml2mmcif_command != "false" ] ; then
  ./scripts/compress_mmcif_validation_alt.sh
 fi

fi

echo
echo Everything is up-to-date.

