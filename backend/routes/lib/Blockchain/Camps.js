const express   =   require('express');
const router    =   express.Router();
const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');
const { body, validationResult } = require("express-validator");
require('dotenv').config();


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

const account_address_1 = process.env.account_1;

// Main private key - token generation

const privateKey1 = Buffer.from(process.env.privatekey_1,'hex');


// GET CAMP DETAILS

router.post('/getCampDetails',
    body('camp_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],   
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

            return res.status(400).json({
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


// GET NUMBERS OF ANGELS WHO INVESTED IN A CAMP

router.post('/getCampsAngelInvestorsCount',
    body('camp_address').not().isEmpty(),
    async(req,res)=>{
        try{
            //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],   
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

            return res.status(400).json({
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
                    error: errors.array()[0],   
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

            return res.status(400).json({
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


