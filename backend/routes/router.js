const express       =   require('express');
const app           =   express();
const cors          =   require("cors");
const path          =   require('path');
const moment        =   require('moment-timezone');


const CollectiveToken   =   require('./blockchain/CollectiveToken');
const Camps             =   require('./blockchain/Camps');
const Auth              =   require('./auth/UserAuth');
const Collective        =   require('./collective/Collective');
const Collab            =   require('./collective/Collab');

// Timezone setup

moment.tz.setDefault("Asia/Kolkata");


//EXPRESS PRESET

app.use(express.json());

app.use(express.urlencoded({
    extended: true
}));

app.use(express.text({ limit: '200mb' }));


// EXPRESS STATIC FILE SERVER

// Media uploaded by the users
app.use('/media',express.static(path.join(__dirname,'/../../../CollectiveMedia')))


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


// Camps APIs

app.use('/api',Camps);


// Collective APIs

app.use('/api',Collective);


// Collab APIs

app.use('/api',Collab);



module.exports = app;