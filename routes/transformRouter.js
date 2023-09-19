const express = require('express');
const router = express.Router();
const { DOMParser, XMLSerializer } = require('xmldom');
const xpath = require('xpath');
const multer = require('multer');
const select = xpath.useNamespaces({ tei: 'http://www.tei-c.org/ns/1.0' });
const parser = new DOMParser();


const storage = multer.memoryStorage();
const upload = multer({storage})

const searchRelevantAncestor = (thisElement) => {
  if(thisElement.parentNode.nodeName === 'rdg' || thisElement.parentNode.nodeName === 'text' || thisElement.parentNode.nodeName === 'tei:rdg' || thisElement.parentNode.nodeName === 'tei:text' || thisElement.parentNode.nodeName === 'tei:lem' || thisElement.parentNode.nodeName === 'lem') {return thisElement.parentNode}
  else {return searchRelevantAncestor(thisElement.parentNode)}
}

router.post('/', upload.single('file'), async (req, res) => {
    if (!req.file) {
      return res.status(400).send('No file uploaded.');
    }
    
    
  
    // Convert the uploaded file buffer to a string
    const fileName = req.file.originalname
    const fileData = req.file.buffer.toString('utf-8');
  
    // Parse the XML content into a DOM object using xmldom
    
    const xmlDoc = parser.parseFromString(fileData, 'text/xml');
    

    const filePath = './uploads/'+fileName;
  
    // Use xpath to select all tei:app elements
  
    const lemElements = select('//tei:lem', xmlDoc);
    const witnesses = select('//tei:witness', xmlDoc);

  
    
    //Order witnesses
    const witnessesToOrder = Array.from(witnesses);

    witnessesToOrder.sort((a, b) => {
      const idA = a.getAttribute('xml:id');
      const idB = b.getAttribute('xml:id');
      return idA.localeCompare(idB);
    });

    const witList = select('//tei:listWit', xmlDoc)[0];

    witnessesToOrder.forEach((thisWitness)=>{
      witList.appendChild(thisWitness);
    })

    const witIDs = new Array;
    witnesses.forEach((witness) => {
        witIDs.push(witness.getAttribute('xml:id'))
    })


    //Force positive apparatus
    lemElements.forEach((thisLem) => {
        const relAnc = searchRelevantAncestor(thisLem);
    let relWits = new Array;
    if(relAnc.nodeName === 'rdg' || relAnc.nodeName === 'tei:rdg' || relAnc.nodeName === 'tei:lem' || relAnc.nodeName === 'lem') {
      relWits = relAnc.getAttribute('wit').split(/\s+/)
    } else {
      witIDs.forEach((thisId => {
        relWits.push('#'+thisId)
      }))
    }
    let siblingRdgs = select('following-sibling::tei:rdg | preceding-sibling::tei:rdg', thisLem);
    siblingRdgs.forEach((thisSibl) => {
      let witArray = thisSibl.getAttribute('wit').split(/\s+/);
      witArray.forEach((thisWit) => {
        if(relWits.includes(thisWit)) {
          relWits = relWits.filter(item => item !== thisWit)
        }
      })
    })
    newWits = relWits.join(' ')
    thisLem.setAttribute('wit', newWits)

    })

    //Order wit ids in wits
    rdgandlems = select('//tei:rdg | //tei:lem', xmlDoc)
    rdgandlems.forEach((thisRL) => {
        idsToOrder = thisRL.getAttribute('wit').split(/\s+/);
        idsToOrder.sort((a, b) => {
          return a.localeCompare(b)
        })
        thisRL.setAttribute('wit', idsToOrder.join(' '))
    })



    const xmlString = new XMLSerializer().serializeToString(xmlDoc);

    //get all wit combinations
    const combListRaw = new Array;
    rdgandlems.forEach((thisRL) => {
      combListRaw.push(thisRL.getAttribute('wit'));
    })

    const witSet = new Set(combListRaw);
    const combList = [...witSet]

    // Sort the combinations by wits number
    let highCount = 0;
    const unsortedWits = new Array;
    const countWits = (thisComb) => {
      let witCount = 0;
      Array.from(thisComb).forEach((thisChar) => {
        if(thisChar === ' ') {
          witCount += 1
        }
        if(witCount>highCount) {
          highCount = witCount
        }
        
      })
      unsortedWits.push({count: witCount, comb:thisComb})
      //rendText += 'High count is '+highCount+'<br/>Wit count is '+witCount+'<br/>'
    }
    combList.forEach((thisComb) => {countWits(thisComb)})
    const sortedWits = new Array;
    for(i = 0; i <= highCount; i++) {
      sortedWits.push(new Array)
    }
    unsortedWits.forEach((thisObj) => {
      let combCount = select('count(//tei:rdg[@wit = "'+thisObj.comb+'"] | //tei:lem[@wit = "'+thisObj.comb+'"])', xmlDoc);
      sortedWits[thisObj.count].push({combination: thisObj.comb, count:combCount, seen: false})
    })
    //Sort combinations alphabetically
    sortedWits.forEach((thisArray) => {
      thisArray.sort((a, b) => {
        return a.combination.localeCompare(b.combination)
      })

    })
    
    req.session.combinations = sortedWits;

    //Transform lems to rdgs
    while(xmlDoc.getElementsByTagName('tei:lem').length>0) {
      
      const lems = xmlDoc.getElementsByTagName('tei:lem');

      for(let i = 0; i<lems.length; i++) {
        let thisLem = lems[i]      
        let newRdg = xmlDoc.createElement('rdg');
        let attributes = thisLem.attributes;
        for(let j=0; j<attributes.length; j++)
        
          {thisAtt = attributes[j];
            newRdg.setAttribute(thisAtt.name, thisAtt.value)}
        
        while(thisLem.childNodes.length>0) {
          newRdg.appendChild(thisLem.childNodes[0])
        }
      
      thisLem.parentNode.replaceChild(newRdg, thisLem)
    }}

    
    while(xmlDoc.getElementsByTagName('lem').length>0) {
      
      const lems = xmlDoc.getElementsByTagName('lem');

      for(let i = 0; i<lems.length; i++) {
        let thisLem = lems[i]      
        let newRdg = xmlDoc.createElement('rdg');
        let attributes = thisLem.attributes;
        for(let j=0; j<attributes.length; j++)
        
          {thisAtt = attributes[j]
            newRdg.setAttribute(thisAtt.name, thisAtt.value)}
        
        while(thisLem.childNodes.length>0) {
          newRdg.appendChild(thisLem.childNodes[0])
        }
      
      thisLem.parentNode.replaceChild(newRdg, thisLem)
    }}
    
    

    //Replace lems with rdgs
    const xmlStringNew = new XMLSerializer().serializeToString(xmlDoc);
    req.session.xml = xmlStringNew;

    //Transformation finished, continue to get
    res.redirect('/main');

  });

module.exports = router;