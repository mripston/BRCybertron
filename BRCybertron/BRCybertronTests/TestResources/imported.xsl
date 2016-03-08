<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs xml"
	version="1.0">
	
	<xsl:template match="passage">
		<div>
			<xsl:apply-templates select="para"/>
		</div>
	</xsl:template>
	
	<xsl:template match="para">
		<p><xsl:value-of select="."/></p>
	</xsl:template>
	
</xsl:stylesheet>
