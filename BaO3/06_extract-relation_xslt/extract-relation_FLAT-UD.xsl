<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="Relation">flat:name</xsl:param>
    <xsl:output method="text" encoding="utf-8" />
    <xsl:template match="/">
        <xsl:apply-templates select=".//p" />
    </xsl:template>
    <xsl:template match="p">
        <xsl:for-each select="item">
            <xsl:if test="contains(./a[8]/text(),$Relation)">
                <xsl:variable name="p1" select="./a[2]/text()" />
                <xsl:variable name="positionCible" select="./a[7]/text()" />
                <xsl:variable name="positionSource" select="./a[1]/text()" />
                <xsl:choose>
                    <xsl:when test="$positionCible &lt; $positionSource">
                        <xsl:variable name="p2" select="preceding-sibling::item[a[1]=$positionCible]/a[2]/text()" />
                        <xsl:value-of select="$p2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$p1" />
                        <xsl:text>
                        </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="p2" select="following-sibling::item[a[1]=$positionCible]/a[2]/text()" />
                        <xsl:value-of select="$p2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$p1" />
                        <xsl:text>
                        </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>