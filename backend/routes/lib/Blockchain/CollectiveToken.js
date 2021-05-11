const express   =   require('express');
const router    =   express.Router();
const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');
require('dotenv').config();


///////////////////////////
//Web3 and contract setup
///////////////////////////

const rpcURL = process.env.rpcUrl;

const web3 = new Web3(rpcURL);

const CollectiveToken = require('../../../build/contracts/CollectiveToken.json');

const contract_address = process.env.contract_address;

const abi = CollectiveToken.abi;

const contract = new web3.eth.Contract(abi,contract_address)


//////////////////////
// Account addresses
/////////////////////

//Main account with which contract is deployed

const account_address_1 = process.env.account_1;

// Testing accounts

const account_address_2 = process.env.account_2;

const account_address_3 = process.env.account_3;

const account_address_4 = process.env.account_4;

const account_address_5 = process.env.account_5;

// Trial account 

const account_address_6 = process.env.trial_account_1;

const account_address_7 = process.env.trial_account_2;



//////////////////
/// Private keys
/////////////////

// Main private key - token generation

const privateKey1 = Buffer.from(process.env.privatekey_1,'hex');

// Testing private key

const privateKey2 = Buffer.from(process.env.privatekey_2,'hex');

const privateKey3 = Buffer.from(process.env.privatekey_3,'hex');

const privateKey4 = Buffer.from(process.env.privatekey_4,'hex');

const privateKey5 = Buffer.from(process.env.privatekey_5,'hex');

// Trial accout private key 

const privateKey6 = Buffer.from(process.env.trial_privatekey_1,'hex');

const privateKey7 = Buffer.from(process.env.trial_privatekey_2,'hex');



// Get users account balance

router.get('/getAccountBalance',async(req,res)=>{
    try{
        const ctvBalance = await contract.methods.balanceOf(account_address_1).call();
        const ethBalance = await web3.eth.getBalance(account_address_1);

        if(!ctvBalance || !ethBalance){
            return res.status(500).json({
                result:false,
                msg:'There was a problem facing the users account balance'
            })
        }

        return res.status(400).json({
            result:true,
            msg:'Account balance fetched',
            CTV_balance:ctvBalance+" CTV",
            ETH_balance:ethBalance+" wei"
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem facing the users account balance'
        })
    }
});


module.exports = router;