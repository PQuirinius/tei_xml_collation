<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xsl xs tei #default">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>


  <xsl:param name="base" select="'#A #Bon #La #Lug #M #V'"/>
  <xsl:param name="allMs" select="'#A #Bon #La #Lo #Lug #M #P1 #P2 #P3 #V'"/>
  <xsl:template name="main" match="/">

    <xsl:variable name="body" select="//tei:body"/>
    <xsl:variable name="baseTok" select="tokenize($base, ' ')"/>
    <xsl:variable name="allTok" select="tokenize($allMs, ' ')"/>
    
    <!-- Tokenize input strings into arrays -->
    
    
    <!-- Find elements in $allMsArray that are not in $baseArray -->
    <xsl:variable name="remMs" select="$allTok[not(. = $baseTok)]"/>
    
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
          select="//tei:rdg[@wit = $base]">
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
  
  <xsl:template name="tableRowA">
    <xsl:param name="allMs"/>
    <xsl:param name="base"/>
    <xsl:param name="textToSplit"/>
    <xsl:param name="currentReading"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <td class="reading{substring-after($thisBase,'#')} main textContainer">

          <xsl:for-each select="$currentReading">
            <xsl:apply-templates select="child::node()">
              <xsl:with-param name="thisBase" select="$thisBase"/>
              <xsl:with-param name="base" select="$base"/>


            </xsl:apply-templates>
          </xsl:for-each>
        </td>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="tableRowA">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
          <xsl:with-param name="currentReading" select="$currentReading"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <td class="reading{substring-after($thisBase,'#')} main textContainer">

            <xsl:for-each select="$currentReading">
              <xsl:apply-templates select="child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>


              </xsl:apply-templates>
            </xsl:for-each>
          </td>
        </xsl:if>

        <xsl:call-template name="tableRowB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$allMs"/>
          <xsl:with-param name="currentReading" select="$currentReading"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="tableRowB">
    <xsl:param name="textToSplit"/>
    <xsl:param name="base"/>
    <xsl:param name="allMs"/>
    <xsl:param name="currentReading"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <xsl:if test="not(contains($base, $thisBase))">
          <xsl:choose>
            <xsl:when test="$currentReading/../tei:rdg/@wit[contains(., $thisBase)]">
              <td class="reading{substring-after($thisBase,'#')} secondary textContainer">
                <xsl:for-each select="$currentReading/../tei:rdg[contains(./@wit, $thisBase)]">

                  <xsl:apply-templates select="child::node()">
                    <xsl:with-param name="thisBase" select="$thisBase"/>
                    <xsl:with-param name="base" select="$base"/>

                  </xsl:apply-templates>
                </xsl:for-each>
              </td>
            </xsl:when>
            <xsl:otherwise>
              <td class="reading{substring-after($thisBase,'#')} textContainer"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="tableRowB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
          <xsl:with-param name="currentReading" select="$currentReading"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <xsl:if test="not(contains($base, $thisBase))">
            <xsl:choose>
              <xsl:when test="$currentReading/../tei:rdg/@wit[contains(., $thisBase)]">
                <td class="reading{substring-after($thisBase,'#')} secondary textContainer">
                  <xsl:for-each select="$currentReading/../tei:rdg[contains(./@wit, $thisBase)]">

                    <xsl:apply-templates select="child::node()">
                      <xsl:with-param name="thisBase" select="$thisBase"/>
                      <xsl:with-param name="base" select="$base"/>

                    </xsl:apply-templates>
                  </xsl:for-each>
                </td>
              </xsl:when>
              <xsl:otherwise>
                <td class="reading{substring-after($thisBase,'#')} textContainer"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="divHeadA">
    <xsl:param name="allMs"/>
    <xsl:param name="base"/>
    <xsl:param name="textToSplit"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <div class="textContainer">
          <xsl:value-of select="substring-after($thisBase, '#')"/>
        </div>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="divHeadA">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <div class="textContainer">
            <xsl:value-of select="substring-after($thisBase, '#')"/>
          </div>
        </xsl:if>

        <xsl:call-template name="divHeadB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$allMs"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="divHeadB">
    <xsl:param name="textToSplit"/>
    <xsl:param name="base"/>
    <xsl:param name="allMs"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <xsl:if test="not(contains($base, $thisBase))">
          <div class="textContainer">
            <xsl:value-of select="substring-after($thisBase, '#')"/>
          </div>
        </xsl:if>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="divHeadB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <xsl:if test="not(contains($base, $thisBase))">
            <div class="textContainer">
              <xsl:value-of select="substring-after($thisBase, '#')"/>
            </div>
          </xsl:if>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="textContainerA">
    <xsl:param name="allMs"/>
    <xsl:param name="base"/>
    <xsl:param name="textToSplit"/>
    <xsl:param name="body"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <div class="textContainer">

          <xsl:for-each select="$body/tei:div//tei:p">
            <xsl:apply-templates select="child::node()">
              <xsl:with-param name="thisBase" select="$thisBase"/>
              <xsl:with-param name="base" select="$base"/>

            </xsl:apply-templates>
          </xsl:for-each>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>
          <br/>

        </div>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="textContainerA">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
          <xsl:with-param name="body" select="$body"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <div class="textContainer">

            <xsl:for-each select="$body/tei:div//tei:p">
              <xsl:apply-templates select="child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>

              </xsl:apply-templates>
            </xsl:for-each>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>

          </div>
        </xsl:if>

        <xsl:call-template name="textContainerB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$allMs"/>
          <xsl:with-param name="body" select="$body"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="textContainerB">
    <xsl:param name="textToSplit"/>
    <xsl:param name="base"/>
    <xsl:param name="allMs"/>
    <xsl:param name="body"/>
    <xsl:choose>
      <xsl:when test="contains($textToSplit, ' ')">
        <xsl:variable name="thisBase" select="substring-before($textToSplit, ' ')"/>
        <xsl:if test="not(contains($base, $thisBase))">
          <div class="textContainer">

            <xsl:for-each select="$body/tei:div//tei:p">
              <xsl:apply-templates select="child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>

              </xsl:apply-templates>
            </xsl:for-each>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>
            <br/>

          </div>
        </xsl:if>
        <xsl:variable name="textToSplit" select="substring-after($textToSplit, ' ')"/>
        <xsl:call-template name="textContainerB">
          <xsl:with-param name="allMs" select="$allMs"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="textToSplit" select="$textToSplit"/>
          <xsl:with-param name="body" select="$body"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($textToSplit = '')">
          <xsl:variable name="thisBase" select="$textToSplit"/>
          <xsl:if test="not(contains($base, $thisBase))">
            <div class="textContainer">

              <xsl:for-each select="$body/tei:div//tei:p">
                <xsl:apply-templates select="child::node()">
                  <xsl:with-param name="thisBase" select="$thisBase"/>
                  <xsl:with-param name="base" select="$base"/>

                </xsl:apply-templates>
              </xsl:for-each>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>
              <br/>

            </div>
          </xsl:if>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>






  <xsl:template match="tei:app">
    <xsl:param name="thisBase"/>
    <xsl:param name="base"/>
    <xsl:choose>
      <xsl:when test="tei:rdg[@wit = $base]">
        <xsl:variable name="countLessons">
          <xsl:value-of select="count(./preceding::tei:rdg[@wit = $base]) + 1"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($base, $thisBase)">
            <span class="apparatEntry{$countLessons} lessonSpan main">
              <xsl:apply-templates select="tei:rdg[contains(@wit, $thisBase)]/child::node()">
                <xsl:with-param name="thisBase" select="$thisBase"/>
                <xsl:with-param name="base" select="$base"/>
              </xsl:apply-templates>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="apparatEntry{$countLessons} lessonSpan secondary">
              <xsl:apply-templates select="tei:rdg[contains(@wit, $thisBase)]/child::node()">
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
    <xsl:text> </xsl:text><span class="add">
      <xsl:apply-templates select="child::node()"/>
    </span>
  </xsl:template>
  <xsl:template match="tei:del">
    <span class="del">
      <xsl:apply-templates select="child::node()"/>
    </span>
  </xsl:template>
  <xsl:template match="tei:unclear"> ¿<xsl:apply-templates select="child::node()"/>? </xsl:template>
  
  <xsl:template match="tei:note"></xsl:template>


</xsl:stylesheet>
