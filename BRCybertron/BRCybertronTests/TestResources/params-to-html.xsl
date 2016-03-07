<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs xml"
	version="1.0">
	
	<xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes" />
	
	<xsl:param name="strength"/>
	<xsl:param name="prowess"/>
	
	<xsl:template match="passage">
		<html>
			<body>
				<xsl:apply-templates select="para"/>
				<dl>
					<dt>Strength</dt>
					<dd><xsl:value-of select="format-number($strength div 100, '#%')"/></dd>
					<dt>Prowess</dt>
					<dd><xsl:value-of select="$prowess"/></dd>
				</dl>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="para">
		<p>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>
	
</xsl:stylesheet>
