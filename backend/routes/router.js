const express       =   require('express');
const app           =   express();
const cors          =   require("cors");


const CollectiveToken   =   require('./lib/Blockchain/CollectiveToken');
const Camps             =   require('./lib/Blockchain/Camps');
const Auth              =   require('./lib/auth/userAuth');

//EXPRESS PRESET

app.use(express.json());

app.use(express.urlencoded({
    extended: true
}));

app.use(express.text({ limit: '200mb' }));


// CORS PRESETS

app.use(cors());

app.use(express.static("docs"));
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'Origin,X-Requested-With,Content-Type,Accept,Authorization');
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PATCH,DELETE,PUT,OPTIONS');
    if (req.method === 'OPTIONS') {
        res.sendStatus(200);
    } else {
        next();
    }
});


// User auth

app.use('/api',Auth);


// Blockchain APIs

app.use('/api',CollectiveToken);

app.use('/api',Camps);


module.exports = app;