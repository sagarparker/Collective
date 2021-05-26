const express   =   require('express');
const router    =   express.Router();
const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');
const moment    =   require('moment-timezone');
const CryptoJS  =   require("crypto-js");
const axios     =   require('axios');
const { body, validationResult }    =   require("express-validator");
const { validateApiSecret,isAuthenticated }   =   require("../auth/authHelper");

require('dotenv').config();

const CampModel         =   require('../../../models/campDetailsMode');
const UserDetailsModel  =   require("../../../models/userDetailsModel");



///////////////////////////
//Web3 and contract setup
///////////////////////////

const rpcURL = 'https://kovan.infura.io/v3/7a0de82adffe468d8f3c1e2183b37c39';

const web3 = new Web3(rpcURL);


const Camps = require('../../../build/contracts/Camps.json');

const contract_address = process.env.camps_contract_address;

const abi = Camps.abi;

const contract = new web3.eth.Contract(abi,contract_address);



////////////////////////////////////
// Account addresses & Private keys
////////////////////////////////////


//Main account with which contract is deployed

const account_address = process.env.account_1;

// Main private key - token generation

const privateKey = Buffer.from(process.env.privateKey_1,'hex');



// CREATE A NEW CROWFUNDING CAMP ON COLLECTIVE

router.post('/createCamp',
    body('camp_name').not().isEmpty(),
    body('camp_target').not().isEmpty(),
    body('camp_equity').not().isEmpty(),
    validateApiSecret,
    isAuthenticated,
    async(req,res)=>{
        try{

            //web3.eth.handleRevert = true;

            //Input field validation

            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const camp_name     =   req.body.camp_name;
            const camp_target   =   req.body.camp_target;
            const camp_equity   =   req.body.camp_equity;


            // Checking if the camp name already exists

            const campExists    =   await CampModel.findOne({name:camp_name});

            if(campExists){
                return res.status(400).json({
                    result:false,
                    msg:'Camp already exists'
                })
            }

            // Create a eth account for camp

            const ethAccount    =   await web3.eth.accounts.create();

            if(!ethAccount){
              return res.status(400).json({
                msg:"There was a problem creating ETH account for the user",
                result:false
              });
            }

            // Using AES to encrypt the Ethereum private key

            let ciphertext = CryptoJS.AES.encrypt(ethAccount.privateKey,process.env.master_key).toString();


            // Saving the camp on Ethereum SC.

            const txCount = await web3.eth.getTransactionCount(account_address);
            if(!txCount){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem creating a Camp'
                })
            }
            // Build the transaction
            const txObject = {
                nonce:    web3.utils.toHex(txCount),
                to:       contract_address,
                gasLimit: web3.utils.toHex(500000),
                gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
                data: contract.methods.createCamp(ethAccount.address,camp_target,camp_equity).encodeABI()
            }
        
            // Sign the transaction
            const tx = new Tx(txObject,{chain:42})
            tx.sign(privateKey)
        
            const serializedTx = tx.serialize()
            const raw = '0x' + serializedTx.toString('hex')


            // Broadcast the transaction

            await web3.eth.sendSignedTransaction(raw);



            // Saving camp details to the database

            const campDetails = new CampModel({
                name        :   camp_name,  
                owner       :   req.decoded.username,
                createdOn   :   moment().format('MMMM Do YYYY, h:mm:ss a'),
                target      :   camp_target,
                equity      :   camp_equity,
                address     :   ethAccount.address,   
                privatekey  :   ciphertext
            });
            

            const newCampDetails = await CampModel.create(campDetails);

            if(!newCampDetails){
                return res.status(400).json({
                    result:false,
                    msg:'There was a problem creating the camp',
                });
            }


            // Saving the camp id to userdetails

            const userDetailsUpdate = await UserDetailsModel.findOneAndUpdate({username:req.decoded.username},{
                $addToSet:{camps_owned:newCampDetails.id}
            })

            if(!userDetailsUpdate){
                return res.status(400).json({
                    result:false,
                    msg:'There was a problem creating the camp',
                });
            }

            return res.status(200).json({
                result:true,
                msg:'Camp created',
                camp:newCampDetails
            });
            
        }
        catch(err){
            console.log(err);
            // console.log(web3.utils.hexToAscii(err.receipt.logsBloom));
            res.status(500).json({
                result:false,
                msg:'There was a problem creating the camp. Note - Camp name needs to be unique.'
            })
        }
});



// BUY EQUITY IN CAMP

router.post('/buyEquity',
    body('camp_address').not().isEmpty(),
    body('amount').not().isEmpty(),
    validateApiSecret,
    isAuthenticated,
    async(req,res)=>{
        try{

            //web3.eth.handleRevert = true;

            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const angel_address     =   req.decoded.eth_address;
            const camp_address      =   req.body.camp_address;
            const amount            =   req.body.amount


            const txCount = await web3.eth.getTransactionCount(account_address);
            if(!txCount){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem creating a Camp'
                })
            }
            // Build the transaction
            const txObject = {
                nonce:    web3.utils.toHex(txCount),
                to:       contract_address,
                gasLimit: web3.utils.toHex(500000),
                gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
                data: contract.methods.buyEquity(angel_address,camp_address,amount).encodeABI()
            }
        
            // Sign the transaction
            const tx = new Tx(txObject,{chain:42})
            tx.sign(privateKey)
        
            const serializedTx = tx.serialize()
            const raw = '0x' + serializedTx.toString('hex')


            // Broadcast the transaction

            const transactionDetails = await web3.eth.sendSignedTransaction(raw);
            if(transactionDetails.logs.length>0){
                console.log("Camp's target reached");
            }
            if(transactionDetails){
                const buyer_private_key = req.decoded.eth_private_key;
                let bytes  = CryptoJS.AES.decrypt(buyer_private_key, process.env.master_key);
                let bytes_key = bytes.toString(CryptoJS.enc.Utf8).slice(2);
                let original_private_key = Buffer.from(bytes_key,'hex');
                

                var data = JSON.stringify({
                    "owner_address": angel_address,
                    "owner_private_key": original_private_key,
                    "transfer_address": camp_address,
                    "amount": amount
                  });
                  
                  var config = {
                    method: 'post',
                    url: 'http://localhost:8080/api/transferCTVbetweenUsers',
                    headers: { 
                      'Content-Type': 'application/json'
                    },
                    data : data
                  };
                  
                  axios(config)
                  .then(function (response) {
                    console.log(JSON.stringify(response.data));
                    res.status(200).json({
                        result:true,
                        msg:'Equity bought in the camp'
                    })
                  })
                  .catch(function (error) {
                    console.log(error);
                    res.status(500).json({
                        result:false,
                        msg:'There was a problem transfering CTV'
                    })
                  });
            }
        }
        catch(err){
            console.log(err);
            // console.log(web3.utils.hexToAscii(err.receipt.logsBloom));
            res.status(500).json({
                result:false,
                msg:'There was a problem buying equity in the camp'
            })
        }
});



// GET CAMP DETAILS

router.post('/getCampDetails',
    body('camp_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const camp_address = req.body.camp_address;

            const campDetails = await contract.methods.camps(camp_address).call();

            if(!campDetails){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the camp details'
                })
            }

            return res.status(200).json({
                result:true,
                msg:'Camp details fetched',
                details:campDetails
            });
            
        }
        catch(err){
            console.log(err);
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the camp details'
            })
        }
});



// GET FUNDING DETAILS

router.post('/getFundingDetails',
    body('camp_address').not().isEmpty(),
    body('angel_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const camp_address  =   req.body.camp_address;
            const angel_address =   req.body.angel_address;

            const fundingDetails = await contract.methods.funding(camp_address,angel_address).call();

            if(!fundingDetails){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the funding details for the camp'
                })
            }

            return res.status(200).json({
                result:true,
                msg:"User's funding towards camp fetched",
                details:fundingDetails
            });
            
        }
        catch(err){
            console.log(err);
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the funding details for the camp'
            })
        }
});



// GET NUMBERS OF ANGELS WHO INVESTED IN A CAMP

router.post('/getCampsAngelInvestorsCount',
    body('camp_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const camp_address = req.body.camp_address;

            const campAngelsList = await contract.methods.getAngelListLength(camp_address).call();

            if(!campAngelsList){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the count of angels'
                })
            }

            return res.status(200).json({
                result:true,
                msg:'Camps Angels count fetched',
                count:campAngelsList
            });
            
        }
        catch(err){
            console.log(err);
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the count of angels '
            })
        }
});


// GET LIST OF ANGEL INVESTORS FOR A CAMP

router.post('/getCampsAngelInvestors',
    body('camp_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const camp_address = req.body.camp_address;

            const campAngelsList = await contract.methods.getAngelList(camp_address).call();

            if(!campAngelsList){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the list of angels'
                })
            }

            return res.status(200).json({
                result:true,
                msg:'Camps Angels list fetched',
                list:campAngelsList
            });
            
        }
        catch(err){
            console.log(err);
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the list of angels '
            })
        }
});




module.exports = router;


