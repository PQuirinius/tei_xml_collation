const express = require('express')
const router = express.Router()
const { DOMParser } = require('xmldom');
const parser = new DOMParser();
const xpath = require('xpath');
const select = xpath.useNamespaces({ tei: 'http://www.tei-c.org/ns/1.0' });


router.get('/', (req, res) => {
    const XML = req.session.xml;
    const DOMXML = parser.parseFromString(XML, 'text/xml');
    const title = select('//tei:titleStmt/tei:title/text()', DOMXML)[0].toString().trim();
    res.render('tables', {
      wits: req.session.wits,
      title: title,
      combinations: req.session.combinations
    })
  })

  module.exports = router;