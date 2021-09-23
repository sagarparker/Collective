const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');
const moment    =   require('moment-timezone');
const CryptoJS  =   require("crypto-js");
const axios     =   require('axios');
const { validationResult }    =   require("express-validator");

require('dotenv').config();

const CampModel         =   require('../../models/campDetailsModel');
const UserAuthModel     =   require('../../models/userAuthModel');
const UserDetailsModel  =   require("../../models/userDetailsModel");
const CollabModel       =   require("../../models/collabModel");   


///////////////////////////
//Web3 and contract setup
///////////////////////////

const rpcURL = 'https://kovan.infura.io/v3/7a0de82adffe468d8f3c1e2183b37c39';

const web3 = new Web3(rpcURL);

const Camps = require('../../build/contracts/Camps.json');

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



const createCamp = async(req,res)=>{
    try{

        // INput field validation

        if(req.file == undefined || req.file.size == 0){
            return res.status(401).json({
                error:"No valid image is provided",
                result:false
            })
        }
        if(req.body.camp_name == "" || req.body.camp_name == undefined){
            return res.status(401).json({
                error:"Input field camp_name is not valid",
                result:false
            })
        }
        if(req.body.camp_target == "" || req.body.camp_target == undefined){
            return res.status(401).json({
                error:"Input field camp_target is not valid",
                result:false
            })
        }
        if(req.body.camp_equity == "" || req.body.camp_equity == undefined){
            return res.status(401).json({
                error:"Input field camp_equity is not valid",
                result:false
            })
        }
        if(req.body.camp_description == "" || req.body.camp_description == undefined){
            return res.status(401).json({
                error:"Input field camp_description is not valid",
                result:false
            })
        }
        if(req.body.long_description == "" || req.body.long_description == undefined){
            return res.status(401).json({
                error:"Input field long_description is not valid",
                result:false
            })
        }
        if(req.body.category == "" || req.body.category == undefined){
            return res.status(401).json({
                error:"Input field category is not valid",
                result:false
            })
        }

        const image_url = `http://3.135.1.141/media/camp/${req.file.filename}`;
        const camp_name         =   req.body.camp_name;
        const camp_target       =   req.body.camp_target;
        const camp_equity       =   req.body.camp_equity;
        const camp_description  =   req.body.camp_description;
        const long_description  =   req.body.long_description;
        const category          =   req.body.category


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
            name                :   camp_name,  
            owner               :   req.decoded.username,
            createdOn           :   moment().format('MMMM Do YYYY, h:mm:ss a'),
            target              :   camp_target,
            equity              :   camp_equity,
            address             :   ethAccount.address,   
            privatekey          :   ciphertext,
            camp_image          :   image_url,
            camp_description    :   camp_description,
            long_description    :   long_description,
            category            :   category
        });
        

        const newCampDetails = await CampModel.create(campDetails);

        if(!newCampDetails){
            return res.status(500).json({
                result:false,
                msg:'There was a problem creating the camp',
            });
        }

        // Saving the camp id to userdetails

        const userDetailsUpdate = await UserDetailsModel.findOneAndUpdate({username:req.decoded.username},{
            $addToSet:{camps_owned:newCampDetails.id}
        })

        if(!userDetailsUpdate){
            return res.status(500).json({
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
}


const getCampList = async(req,res)=>{
    try{

        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const sort_by   =   req.body.sort_by;

        let campList;

        if(sort_by == "Latest"){
             campList = (await CampModel.find({})).reverse();
        }
        else if(sort_by == "High target"){
            campList = await CampModel.find({}).sort({target:-1});
        }
        else if(sort_by == "Low target"){
            campList = await CampModel.find({}).sort({target:1});
        }
        
        if(campList.length == 0){
            return res.status(500).json({
                result:false,
                msg:'No camps found'
            })
        }

        return res.status(200).json({
            result:true,
            msg:'Camp list fetched',
            details:campList
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching the camp list'
        })
    }
}


const buyEquity = async(req,res)=>{
    try{


        //Input field validation
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const angel_address     =   req.decoded.eth_address;
        const camp_address      =   req.body.camp_address;
        const amount            =   req.body.amount;


        const buyer_private_key     =   req.decoded.eth_private_key;
        let bytes                   =   CryptoJS.AES.decrypt(buyer_private_key, process.env.master_key);
        let bytes_key               =   bytes.toString(CryptoJS.enc.Utf8).slice(2);
        let original_private_key    =   Buffer.from(bytes_key,'hex');
        

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
          .then(async function (response) {

            console.log(JSON.stringify(response.data));

            if(response.data.result == true){

                const txCount = await web3.eth.getTransactionCount(account_address);
                if(!txCount){
                    return res.status(500).json({
                        result:false,
                        msg:'There was a problem in transaction'
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
                    const campUpdate = await CampModel.findOneAndUpdate({address:camp_address},{targetReachedDB:true});
                    if(!campUpdate){
                        console.log('\nThere was a problem updating the targetReached status');
                    }
                    console.log("\nCamp's target reached !!!!");
                }
                if(transactionDetails.status){
                    
                    // Saving the camp id to userdetails

                    const campDetails = await CampModel.findOne({address:camp_address});
                    if(!campDetails){
                        console.log('\nCamp not found');
                    }
    
                    const userDetailsUpdate = await UserDetailsModel.findOneAndUpdate({username:req.decoded.username},{
                        $addToSet:{camps_invested:campDetails.id}
                    })
    
                    if(!userDetailsUpdate){
                        console.log('There was a problem updating your investment list');
                    }
    
                    console.log("\nCamp added to Users investment list");
    
                    res.status(200).json({
                        result:true,
                        msg:'Equity bought in the camp'
                    });
                }
                else if (transactionDetails.status == false){
                    res.status(500).json({
                        result:false,
                        msg:'There was a problem buying equity in the camp'
                    })
                }
            }
            else{
                res.status(500).json({
                    result:false,
                    msg:'There was a problem buying equity in the camp'
                })
            }
          })
          .catch(function (error) {
            console.log(error);
            return res.status(500).json({
                result:false,
                msg:'There was a problem transfering CTV'
            })
          });
    }
    catch(err){
        console.log(err);
        // console.log(web3.utils.hexToAscii(err.receipt.logsBloom));
        res.status(500).json({
            result:false,
            msg:'There was a problem buying equity in the camp'
        })
    }
}


const getCampDetails = async(req,res)=>{
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
}


const getCampMasterDetails = async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const camp_address = req.body.camp_address;

        const campDetailsSC     =   await contract.methods.camps(camp_address).call();
        const campDetailsDB     =   await CampModel.findOne({address:camp_address},{target:0,equity:0});   
        
    

        if(!campDetailsSC || !campDetailsDB){
            return res.status(404).json({
                result:false,
                msg:'Camp not found'
            })    
        }

        const campCollabCount = await CollabModel.countDocuments({
            campID                      :   campDetailsDB._id,
            collaboratorSearchActive    :   false
        });


        const campDetailsMaster = {
            ...campDetailsSC,
            ...campDetailsDB._doc,
            campCollabCount
        }

        return res.status(200).json({
            result:true,
            msg:'Camp details fetched',
            details:campDetailsMaster
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching the camp details'
        })
    }
}


const getFundingDetails = async(req,res)=>{
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
}


const getCampsAngelInvestorsCount = async(req,res)=>{
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
}


const getCampsAngelInvestors = async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const camp_address = req.body.camp_address;

        // Fetching data from SC - ethereum

        const campAngelsList = await contract.methods.getAngelList(camp_address).call();

        if(!campAngelsList){
            return res.status(500).json({
                result:false,
                msg:'There was a problem fetching the list of angels'
            })
        }
        
        // Fetching user details with ETH address

        const angelsUsername = await UserAuthModel.find({
            eth_address : {
                $in : campAngelsList
            }
        },{eth_private_key:0,password:0});

        if(!angelsUsername){
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the list of angels '
            })
        }

        return res.status(200).json({
            result:true,
            msg:'Camps Angels list fetched',
            list:angelsUsername
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching the list of angels '
        })
    }
}


const getCampsCreatedByUser = async(req,res)=>{
    try{

        const campList = await UserDetailsModel.findOne({username:req.decoded.username},{camps_owned:1}).populate("camps_owned"); 

        if(!campList){
            return res.status(500).json({
                result:false,
                msg:'There was a problem fetching camps'
            })
        }

        return res.status(200).json({
            result:true,
            msg:'Camps fetched',
            details:campList.camps_owned
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching camps created by the user'
        })
    }
}


const getCampsInvestedByUser = async(req,res)=>{
    try{

        const campList = await UserDetailsModel.findOne({username:req.decoded.username},{camps_invested:1}).populate("camps_invested"); 

        if(!campList){
            return res.status(500).json({
                result:false,
                msg:'There was a problem fetching camps'
            })
        }

        return res.status(200).json({
            result:true,
            msg:'Camps fetched',
            details:campList.camps_invested
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching camps invested by the user'
        })
    }
}


const getUsersCollabs = async(req,res)=>{
    try{

        const campList = await UserDetailsModel.findOne({username:req.decoded.username},{camps_collaborated:1})
            .populate("camps_collaborated",{collabRequests:0}); 

        if(!campList){
            return res.status(500).json({
                result:false,
                msg:'There was a problem fetching users collabs'
            })
        }

        return res.status(200).json({
            result:true,
            msg:'Collabs jobs fetched',
            details:campList.camps_collaborated
        });
        
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem fetching users collabs'
        })
    }
}


const searchCamp = async(req,res)=>{
    try{
        // Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        let camp_name = req.body.camp_name;
        

        // Search for camp with regex

        const camps = await CampModel.find({"name": { $regex : camp_name,'$options' : 'i' }});

        if(camps.length == 0){
            return res.status(404).json({
                msg:"No camps found",
                result:false
            })
        }

        return res.status(200).json({
            msg:"Camps matching to the search query",
            result:true,
            camps
        })
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            msg:"Error in searching for camps",
            result:false
        })
    }
}



module.exports = {
    createCamp,
    getCampList,
    buyEquity,
    getCampDetails,
    getCampMasterDetails,
    getFundingDetails,
    getCampsAngelInvestorsCount,
    getCampsAngelInvestors,
    getCampsCreatedByUser,
    getCampsInvestedByUser,
    getUsersCollabs,
    searchCamp
}

