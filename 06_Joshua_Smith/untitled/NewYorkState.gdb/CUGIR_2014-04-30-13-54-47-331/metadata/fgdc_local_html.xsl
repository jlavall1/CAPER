<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" omit-xml-declaration="yes" />
<!--

An XSL stylesheet for displaying FGDC metadata as HTML
IMPORTANT! The file "fgdc_labels.xml" must be in the same directory as this stylesheet.

REVERSE CHRONOLOGY
==================

Revised 2008-05-27 KGJ
    Wrap <pre> around text blocks containing double linebreaks
    Edited CSS

Revised 2006-05-10 KGJ
    Fixed bug in <xsl:template name="text"> by adding condition in <xsl:variable name="url">

Revised 2006-01-30 KGJ
    Minor edits, mainly to CSS

Revised 2005-10-14 KGJ
    Changed labels to italics only
    Cleaned-up TOC links
    
Revised 2005-09-22 KGJ
    Improved e-mail and URL linking.
    Now checks for hyperlinks <http:...> within text fields.
        
Created 2005-02-07 by:
    Keith Jenkins
    Mann Library
    Cornell University
    Ithaca, NY 14853
    kgj2 [at-sign] cornell [period] edu

-->

<xsl:template match="//metadata">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <style type="text/css">
            body { font-family:"Cambria", "Times New Roman", serif }
            div { margin:0 ; padding:0 0 0 2em ; text-indent:-2em }
            em { font-weight:normal ; font-style:italic ; color:#600 }
            h1 { font-size:125% }
            hr { margin:1em 0 }
            pre { font-family:inherit ; margin:0 ; text-indent:0 }
        </style>
    </head>
    <body>
        <h1><xsl:value-of select="idinfo/citation/citeinfo/title" /></h1>
        <ul>
            <xsl:for-each select="child::*">
                <li><a>
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="name()" />
                        </xsl:attribute>
                        <xsl:call-template name="label">
                            <xsl:with-param name="element" select="name()" />
                        </xsl:call-template>
                </a></li>
            </xsl:for-each>
        </ul>
        <xsl:apply-templates />
    </body>
</html>
</xsl:template>



<xsl:template match="metadata//*">
    <xsl:if test="parent::metadata">
        <a>
            <xsl:attribute name="name">
                <xsl:value-of select="name()" />
            </xsl:attribute>
        </a>
        <hr />
    </xsl:if>
    <div>
        <em>
            <xsl:call-template name="label">
                <xsl:with-param name="element" select="name()" />
            </xsl:call-template>
            <xsl:text>: </xsl:text>
        </em>
        <xsl:apply-templates />
    </div>
</xsl:template>


<xsl:template match="cntemail/text()">
    <!-- LINK E-MAIL ADDRESSES 
        (EVEN IF THEY INCORRECTLY ALREADY HAVE 'mailto:') -->
    <xsl:variable name="email">
        <xsl:choose>
            <xsl:when test="starts-with(., 'mailto:')">
                <xsl:value-of select="substring-after(., 'mailto:')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <a>
        <xsl:attribute name="href">
            <xsl:value-of select="concat('mailto:', $email)" />
        </xsl:attribute>
        <xsl:value-of select="$email" />
    </a>
</xsl:template>



<xsl:template name="label">
    <!-- OUTPUT THE HUMAN-READABLE LABEL FOR AN XML ELEMENT -->
    <xsl:param name="element" />
    <xsl:value-of select="document('fgdc_labels.xml')//label[@element=$element]" />
</xsl:template>



<xsl:template match="onlink/text() | networkr/text()">
    <!-- LINK ONLINE LINKS
        (EVEN IF THEY INCORRECTLY HAVE &lt; and &gt; AROUND THE URL -->
    <xsl:variable name="url">
        <xsl:choose>
            <xsl:when test="starts-with(., '&lt;')">
                <xsl:value-of select="substring-before(substring-after(., '&lt;'), '&gt;')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <a>
        <xsl:attribute name="href"><xsl:value-of select="$url" /></xsl:attribute>
        <xsl:value-of select="$url" />
    </a>
</xsl:template>



<xsl:template name="text" match="text()">
    <!-- CHECK TEXT FIELDS FOR DOUBLE LINEBREAKS,
         AND LINKS DELINEATED WITH &lt; and &gt;
             &lt;http://example.org/&gt;
    -->
    <xsl:param name="str" select="." />
    <xsl:param name="pre">0</xsl:param>
    <xsl:variable name="linkstart">&lt;http:</xsl:variable>
    <xsl:variable name="linkstop">&gt;</xsl:variable>
    <xsl:variable name="url">
        <xsl:if test="substring-before(substring-after($str, $linkstart), $linkstop)">
            <xsl:value-of select="concat('http:', substring-before(substring-after($str, $linkstart), $linkstop))" />
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="before">
        <xsl:value-of select="substring-before($str, $url)" />
    </xsl:variable>
    <xsl:variable name="after">
        <xsl:value-of select="substring-after($str, $url)" />
    </xsl:variable>

    <xsl:choose>

        <!-- If we haven't already done so, look for double linebreaks -->
        <xsl:when test="$pre=0 and contains($str, '&#xA;&#xA;')">
            <pre>
                <xsl:call-template name="text">
                    <xsl:with-param name="str">
                        <xsl:choose>
                            <xsl:when test="substring($str,1,1)='&#xA;'">
                                <xsl:value-of select="substring($str,2)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$str" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="pre">1</xsl:with-param>
                </xsl:call-template>
                <xsl:text>
</xsl:text>
            </pre>
        </xsl:when>

        <!-- Handle embedded links -->
        <xsl:when test="string-length($before)&gt;0">
            <xsl:call-template name="text">
                <xsl:with-param name="str" select="$before" />
                <xsl:with-param name="pre">1</xsl:with-param>
            </xsl:call-template>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$url" />
                </xsl:attribute>
                <xsl:value-of select="$url" />
            </a>
            <xsl:if test="$after">
                <xsl:call-template name="text">
                    <xsl:with-param name="str" select="$after" />
                    <xsl:with-param name="pre">1</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:when>

        <!-- Handle regular text -->
        <xsl:otherwise>
            <xsl:value-of select="$str" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


</xsl:stylesheet>
