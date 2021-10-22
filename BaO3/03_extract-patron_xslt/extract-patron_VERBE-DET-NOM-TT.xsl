<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:template match="/">
        <xsl:apply-templates select=".//article" />
    </xsl:template>
    <xsl:template match="article">
        <xsl:for-each select="element">
            <xsl:if test="(./data[1][contains(text(),'VER')])">
                <xsl:variable name="p1" select="./data[3]/text()" />
                <xsl:if test="following-sibling::element[1][./data[1][contains(text(),'DET')]]">
                    <xsl:variable name="p2" select="following-sibling::element[1]/data[3]/text()" />
                    <xsl:if test="following-sibling::element[2][./data[1][contains(text(),'NOM')]]">
                        <xsl:variable name="p3" select="following-sibling::element[2]/data[3]/text()" />
                        <xsl:value-of select="$p1" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$p2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$p3" />
                        <xsl:text> &#xa;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>