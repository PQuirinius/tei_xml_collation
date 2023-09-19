<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xsl xs tei #default">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>


  <xsl:param name="base" select="'#M #V'"/>
  <xsl:param name="allMs" select="'#A #Bon #La #Lo #Lug #M #P1 #P2 #P3 #V'"/>
  <xsl:template name="main" match="/">
    <xsl:variable name="baseTok" select="tokenize($base, ' ')"/>
    <xsl:variable name="allTok" select="tokenize($allMs, ' ')"/>

    <!-- Tokenize input strings into arrays -->


    <!-- Find elements in $allMsArray that are not in $baseArray -->
    <xsl:variable name="remMs" select="$allTok[not(. = $baseTok)]"/>
    <xsl:variable name="body" select="//tei:body"/>

    <table id="lessons">
      <colgroup>
        <xsl:for-each select="$allTok">
          <col span="1" class="butCol"/>
        </xsl:for-each>
      </colgroup>
      <thead>
        <tr>
          <th class="button"/>
          <xsl:for-each select="$baseTok">
            <th class="textContainer colHead" id="head{substring-after(., '#')}">
              <xsl:value-of select="substring-after(., '#')"/>
            </th>
          </xsl:for-each>
          <xsl:for-each select="$remMs">
            <th class="textContainer colHead" id="head{substring-after(., '#')}">
              <xsl:value-of select="substring-after(., '#')"/>
            </th>
          </xsl:for-each>
        </tr>
      </thead>
      <tbody>

        <xsl:for-each
          select="//tei:rdg[descendant-or-self::tei:rdg[@wit = $base]][not(ancestor::tei:rdg)]">
          <xsl:variable name="currentReading" select="."/>
          <xsl:variable name="loopNumber">
            <countNo>
              <xsl:value-of select="position()"/>
            </countNo>
          </xsl:variable>
          <tr id="row{$loopNumber}">
            <td class="button">
              <button id="button{$loopNumber}" class="readingButton">Apparatus entry <xsl:value-of
                  select="$loopNumber"/></button>
            </td>
            <xsl:for-each select="$baseTok">
              <td class="reading{substring-after(.,'#')} main textContainer">
                <xsl:apply-templates select="$currentReading/child::node()">
                  <xsl:with-param name="thisBase" select="."/>
                  <xsl:with-param name="base" select="$base"/>
                </xsl:apply-templates>
              </td>
            </xsl:for-each>
            <xsl:for-each select="$remMs">
              <xsl:variable name="theBase" select="."/>
              <xsl:choose>
                <xsl:when
                  test="$currentReading/ancestor::tei:app[1]/child::tei:rdg[contains(./@wit, $theBase)]">
                  <td class="reading{substring-after(.,'#')} secondary textContainer">
                    <xsl:apply-templates
                      select="$currentReading/ancestor::tei:app[1]/child::tei:rdg[contains(./@wit, $theBase)]">
                      <xsl:with-param name="thisBase" select="."/>
                      <xsl:with-param name="base" select="$base"/>
                    </xsl:apply-templates>
                  </td>
                </xsl:when>
                <xsl:otherwise>
                  <td class="textContainer"/>
                </xsl:otherwise>
              </xsl:choose>

            </xsl:for-each>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
    <hr/>
    <div id="manuscripts">
      <div id="signContainer">
        <xsl:for-each select="$baseTok">
          <div class="textContainer">
            <xsl:value-of select="substring-after(., '#')"/>
          </div>
        </xsl:for-each>
        <xsl:for-each select="$remMs">
          <div class="textContainer">
            <xsl:value-of select="substring-after(., '#')"/>
          </div>
        </xsl:for-each>
      </div>
      <div id="transcriptionContainer">
        <xsl:for-each select="$baseTok">
          <xsl:variable name="theBase" select="."/>
          <xsl:for-each select="$body/tei:div">
            <div class="textContainer">
              <xsl:apply-templates select="child::node()">
                <xsl:with-param name="thisBase" select="$theBase"/>
                <xsl:with-param name="base" select="$base"/>
              </xsl:apply-templates>
              <xsl:for-each select="1 to 20">
                <br/>
              </xsl:for-each>
            </div>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$remMs">
          <xsl:variable name="theBase" select="."/>
          <xsl:for-each select="$body/tei:div">
            <div class="textContainer">
              <xsl:apply-templates select="child::node()">
                <xsl:with-param name="thisBase" select="$theBase"/>
                <xsl:with-param name="base" select="$base"/>

              </xsl:apply-templates>
              <xsl:for-each select="1 to 20">
                <br/>
              </xsl:for-each>
            </div>
          </xsl:for-each>
        </xsl:for-each>
      </div>
    </div>
    <button id="backButton">Back to table</button>
  </xsl:template>

  <xsl:template match="tei:app">
    <xsl:param name="thisBase"/>
    <xsl:param name="base"/>
    <xsl:choose>
      <xsl:when
        test=".[descendant::tei:rdg[@wit = $base]][not(ancestor::tei:rdg)]">
        <xsl:variable name="countLessons">
          <xsl:value-of
            select="count(preceding::tei:app[descendant::tei:rdg[@wit = $base]][not(ancestor::tei:rdg)]) + 1"
          />
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($base, $thisBase)">
            <span class="apparatEntry{$countLessons} lessonSpan main">
              <xsl:apply-templates
                select="tei:rdg[contains(@wit, $thisBase)]/child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>
              </xsl:apply-templates>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="apparatEntry{$countLessons} lessonSpan secondary">
              <xsl:apply-templates
                select="tei:rdg[contains(@wit, $thisBase)]/child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>
              </xsl:apply-templates>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="tei:rdg[contains(./@wit, $thisBase)]">
          <xsl:apply-templates select="child::node()">
            <xsl:with-param name="thisBase" select="$thisBase"/>
            <xsl:with-param name="base" select="$base"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:add">
    <xsl:text> </xsl:text>
    <span class="add">
      <xsl:apply-templates select="child::node()"/>
    </span>
  </xsl:template>
  <xsl:template match="tei:del">
    <span class="del">
      <xsl:apply-templates select="child::node()"/>
    </span>
  </xsl:template>
  <xsl:template match="tei:unclear"> ¿<xsl:apply-templates select="child::node()"/>? </xsl:template>

  <xsl:template match="tei:note"/>


</xsl:stylesheet>
