const express = require('express');
const app = new express();
const crypto = require('crypto');
const session = require('express-session');
const bodyParser = require('body-parser');


const mainRouter = require('./routes/transformRouter.js')
const tablesRouter = require('./routes/tablesRouter.js')
const consultRouter = require('./routes/consultRouter.js')

//Attach view engine and folder
app.set('view engine', 'ejs')
app.use(express.static('public'));

app.use(bodyParser.json())

const PORT = process.env.PORT || 3000;


//Setup session
const sessionSecret = crypto.randomBytes(32).toString('hex');
app.use(session({
  secret: sessionSecret,
  resave: false,
  saveUninitialized: true,
  cookie: {
    secure: false,
    maxAge: 24 * 60 * 60 * 1000,
  },
}));
//Attach routers 
app.use('/main', mainRouter)
app.use('/main', consultRouter)
app.use('/tables', tablesRouter)
app.get('/', (req, res) => {
    res.render('form');
  });

//Set port
app.listen(PORT, () => {console.log('Hello, there!')})


