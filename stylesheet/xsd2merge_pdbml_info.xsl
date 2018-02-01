<?xml version="1.0" encoding="UTF-8"?>
<xsl2:stylesheet
   version="2.0"
   xmlns:xsl2="http://www.w3.org/1999/XSL/Transform"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema">

  <xsl2:output method="xml" indent="yes"/>
  <xsl2:strip-space elements="*"/>

  <xsl2:template match="/">
    <xsl2:text disable-output-escaping="yes">
&lt;xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:PDBxv="http://pdbml.pdb.org/schema/pdbx-validation-v0.xsd"&gt;
</xsl2:text>
    <xsl2:apply-templates/>
    <xsl2:text disable-output-escaping="yes">
&lt;/xsl:stylesheet&gt;</xsl2:text>
  </xsl2:template>

  <xsl2:variable name="merge_categories">pdbx_validate_rmsd_angle pdbx_validate_rmsd_bond pdbx_validate_close_contact pdbx_validate_symm_contact</xsl2:variable>

  <xsl2:template match="/xsd:schema">
    <xsl2:text disable-output-escaping="yes">
  &lt;xsl:param name="info_ext_file" required="yes"/&gt;
  &lt;xsl:param name="info_ext" select="document($info_ext_file)"/&gt;

  &lt;xsl:output method="xml" indent="yes"/&gt;
  &lt;xsl:strip-space elements="*"/&gt;

  &lt;xsl:variable name="entry_id"&gt;&lt;xsl:value-of select="/PDBxv:datablock/PDBxv:entryCategory/PDBxv:entry/@id"/&gt;&lt;/xsl:variable&gt;
  &lt;xsl:variable name="datablock_name"&gt;&lt;xsl:value-of select="concat($entry_id,'-validation')"/&gt;&lt;/xsl:variable&gt;

  &lt;xsl:template match="/"&gt;
    &lt;PDBxv:datablock datablockName="{$datablock_name}" xsi:schemaLocation="http://pdbml.pdb.org/schema/pdbx-validation-v0.xsd pdbx-validation-v0.xsd"&gt;
      &lt;xsl:apply-templates select="PDBxv:datablock/*[not(</xsl2:text>

    <xsl2:for-each select="tokenize($merge_categories,' ')">
      <xsl2:text disable-output-escaping="yes">local-name()='</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category'</xsl2:text>
      <xsl2:if test="position()!=last()"><xsl2:text disable-output-escaping="yes"> or </xsl2:text></xsl2:if>
    </xsl2:for-each>

    <xsl2:text disable-output-escaping="yes">)]"/&gt;
      &lt;xsl:apply-templates select="$info_ext/PDBxv:datablock/*[not(local-name()='entryCategory' or </xsl2:text>

    <xsl2:for-each select="tokenize($merge_categories,' ')">
      <xsl2:text disable-output-escaping="yes">local-name()='</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category'</xsl2:text>
      <xsl2:if test="position()!=last()"><xsl2:text disable-output-escaping="yes"> or </xsl2:text></xsl2:if>
    </xsl2:for-each>

    <xsl2:text disable-output-escaping="yes">)]"/&gt;
</xsl2:text>

    <xsl2:for-each select="tokenize($merge_categories,' ')">
      <xsl2:text disable-output-escaping="yes">
      &lt;xsl:call-template name="merge_</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">"/&gt;
</xsl2:text>
    </xsl2:for-each>
    <xsl2:text disable-output-escaping="yes">
    &lt;/PDBxv:datablock&gt;
  &lt;/xsl:template&gt;
</xsl2:text>
    <xsl2:call-template name="categories"/>
      <xsl2:text disable-output-escaping="yes">
  &lt;xsl:template match="PDBxv:*" mode="category-element"&gt;
    &lt;xsl:element name="{name()}"&gt;
      &lt;xsl:apply-templates select="@*|node()" mode="data-item"/&gt;
    &lt;/xsl:element&gt;
  &lt;/xsl:template&gt;

  &lt;xsl:template match="@*" mode="category-element"&gt;
    &lt;xsl:copy/&gt;
  &lt;/xsl:template&gt;

  &lt;xsl:template match="PDBxv:*" mode="data-item"&gt;
    &lt;xsl:element name="{name()}"&gt;
      &lt;xsl:apply-templates select="@*|node()" mode="data-item"/&gt;
    &lt;/xsl:element&gt;
  &lt;/xsl:template&gt;

  &lt;xsl:template match="node()" mode="data-item"&gt;
    &lt;xsl:copy/&gt;
  &lt;/xsl:template&gt;

  &lt;xsl:template match="@*" mode="data-item"&gt;
    &lt;xsl:copy/&gt;
  &lt;/xsl:template&gt;
</xsl2:text>

    <xsl2:for-each select="tokenize($merge_categories,' ')">
      <xsl2:text disable-output-escaping="yes">
  &lt;xsl:template name="merge_</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">"&gt;
    &lt;xsl:if test="PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category or $info_ext/PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category"&gt;
      &lt;xsl:element name="PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category"&gt;
        &lt;xsl:if test="PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category"&gt;
          &lt;xsl:apply-templates select="PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category/*" mode="category-element"/&gt;
        &lt;/xsl:if&gt;
        &lt;xsl:if test="$info_ext/PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category"&gt;
          &lt;xsl:apply-templates select="$info_ext/PDBxv:datablock/PDBxv:</xsl2:text><xsl2:value-of select="."/><xsl2:text disable-output-escaping="yes">Category/*" mode="category-element"/&gt;
        &lt;/xsl:if&gt;
      &lt;/xsl:element&gt;
    &lt;/xsl:if&gt;
  &lt;/xsl:template&gt;
</xsl2:text>
    </xsl2:for-each>

    <xsl2:text disable-output-escaping="yes">
  &lt;xsl:template match="*[@xsi:nil='true']"/&gt;
  &lt;xsl:template match="*|text()|@*"/&gt;
</xsl2:text>
  </xsl2:template>

  <xsl2:template name="categories">
    <xsl2:for-each select="xsd:complexType[@name='datablockType']/xsd:all/xsd:element">
      <xsl2:call-template name="category">
        <xsl2:with-param name="name" select="@name"/>
      </xsl2:call-template>
    </xsl2:for-each>
  </xsl2:template>

  <xsl2:template name="category">
    <xsl2:param name="name"/>
    <xsl2:text disable-output-escaping="yes">
  &lt;xsl:template match="PDBxv:</xsl2:text><xsl2:value-of select="$name"/><xsl2:text disable-output-escaping="yes">"&gt;
    &lt;xsl:element name="{name()}"&gt;
      &lt;xsl:apply-templates mode="category-element"/&gt;
    &lt;/xsl:element&gt;
  &lt;/xsl:template&gt;
</xsl2:text>
  </xsl2:template>

</xsl2:stylesheet>
