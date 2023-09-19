const express = require('express');
const router = express.Router();
const { DOMParser } = require('xmldom');
const xpath = require('xpath');
const select = xpath.useNamespaces({ tei: 'http://www.tei-c.org/ns/1.0' });
const parser = new DOMParser();
const SaxonJS = require('saxon-js')

const env = SaxonJS.getPlatform();
const xsltPath1 = 'xslt/transformatio1.xsl';
const doc1 = env.parseXmlFromString(env.readFile(xsltPath1));
doc1._saxonBaseUri = "file:///";

const sef1 = SaxonJS.compile(doc1);

const xsltPath2 = 'xslt/transformatio2.xsl';

const doc2 = env.parseXmlFromString(env.readFile(xsltPath2));
doc2._saxonBaseUri = "file:///";
const sef2 = SaxonJS.compile(doc2);

router.get('/', (req, res) => {
    const XML = req.session.xml;
     const DOMXML = parser.parseFromString(XML, 'text/xml');
     
     const title = select('//tei:titleStmt/tei:title/text()', DOMXML)[0].toString().trim();
     
 
     //objectToHtml(output.principalResult.childNodes[0])
     const method = req.query.method;
     let rootBol
     let closestBol
     let sef
     if(!req.query.method) {
       rootBol = true;
       sef = sef2;
       closestBol = false
     } else {
       if(method === 'closest') {
         rootBol = false;
         sef = sef1;
         closestBol = true;
       } else {
         rootBol =true;
         sef = sef2;
         closestBol =false
       }
     }
     let mscr;
     let displayJS
     if(!req.query.mscr) {
        mscr = []
     } else {mscr = req.query.mscr}
     
 
     const witnesses = Array.from(select('//tei:witness', DOMXML));
     const allMsArray = new Array
     const witsForTables = new Array
     witnesses.forEach((thisWit) => {allMsArray.push('#'+thisWit.getAttribute('xml:id'))
     witsForTables.push(thisWit.getAttribute('xml:id'))
   })
     req.session.wits = witsForTables
     const allMs = allMsArray.join(' ');
     const base = mscr.join(' ')
    
     if(select('count(//node()[@wit = "'+base+'"])', DOMXML) === 0) {
       displayJS = false
     } else {displayJS = true}
  
     output = SaxonJS.transform(
       {
         stylesheetInternal: sef,
         sourceType: 'xml',
         sourceText: XML,
         initialTemplate: 'main',
         outputProperties: {method: "xml", indent: true
         
         },
         stylesheetParams: {allMs: allMs,
     base: base}
       },
     )
     
     let HTML = '';
     const objectToHtml = (thisObject) => {
       if(thisObject.nodeType === 1)
       {HTML += '<'+thisObject.nodeName;
       for(let i = 0; i<thisObject.attributes.length; i++) {
         thisAttr = thisObject.attributes[i];
         HTML += ' '+thisAttr.name+'="'+thisAttr.nodeValue+'"';
       }
       HTML += '>'
 
       for(let j = 0; j<thisObject.childNodes.length; j++) {
         
         objectToHtml(thisObject.childNodes[j])
       }
       HTML += '</'+thisObject.nodeName+'>'}
       if(thisObject.nodeType === 3) {
         HTML += thisObject.nodeValue;
       }
     }

     let startForm = ''
     witnesses.forEach((thisWit) => {
       let witID = thisWit.getAttribute('xml:id')
       
        startForm += '<label for="chbx'+witID+'">'+witID+'</label><input id="chbx'+witID+'" value="#'+witID+'" name="mscr[]" type="checkbox"'
        if(mscr.includes('#'+witID)) {startForm += ' checked'};
        startForm += '/>'
     })
 
     for(let k =0; k<output.principalResult.childNodes.length; k++) {
       objectToHtml(output.principalResult.childNodes[k])
     }
    
    let presentCount = mscr.length -1;
    let presentMscr = mscr.join(' ')

    if(presentCount>-1) {
     req.session.combinations[presentCount].forEach((thisComb) => {
       if(thisComb.combination === presentMscr) {
         thisComb.seen = true;
       }
     })
    }

     res.render('mainPage', {
       title: title,
       form: startForm,
       tables: HTML,
       root: rootBol,
       closest: closestBol,
       displayJS: displayJS
     })    
   })

   module.exports = router;