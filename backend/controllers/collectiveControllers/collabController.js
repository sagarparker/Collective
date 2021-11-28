const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');

const UserAuthModel     = require("../../models/userAuthModel");

const UserDetailsModel  = require("../../models/userDetailsModel");
const CollabModel       = require("../../models/collabModel");

const { validationResult } = require("express-validator");

require('dotenv').config();


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



const newCollabJobForCamp = async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        let { camp_id,camp_owner_username,collab_title,collab_amount,collab_description } = req.body;


        // Update the collab section

        const newCollab = await CollabModel.create({
            campID              :   camp_id,
            campOwnerUsername   :   camp_owner_username,
            collabTitle         :   collab_title,
            collabAmount        :   collab_amount,
            collabDescription   :   collab_description
        });


        if(!newCollab){
            return res.status(500).json({
                result:false,
                msg:'There was a problem creating a new collab job.'
            })
        }

        return res.status(500).json({
            result:true,
            msg:"New Collab job added to the camp."
        })
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem creating a new  collab job.'
        })
    }
}


const getAllCollabJobForACamp = async(req,res)=>{
    try{

        let campID = req.params.id;

        if(campID == null || campID == undefined){
            return res.status(400).json({
                result:false,
                msg:"Camp ID is not valid"
            })
        }

        const collabJobs = await CollabModel.find({campID,collaboratorSearchActive:true});

        if(collabJobs.length == 0){
            return res.status(404).json({
                result:false,
                msg:"No collab jobs for camp found"
            })
        }

        return res.status(200).json({
            result:true,
            msg:"Collab jobs for the camps fetched",
            collabJobs
        })

    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:"There was a problem fetching collab jobs for a camp"
        });
    }
}


const sendRequestToCollab = async(req,res)=>{
    try{

        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const collab_job_id =   req.body.collab_job_id;
        const username  =   req.decoded.username;
        const address   =   req.decoded.eth_address


        let userDataObj = {
            username,
            address
        }

        // How the API works;
        // 1. Fetch the requests from the database and build an object for constant time searching
        // 2. If the object already has username inside it return - request already sent
        // 3. Else enter the new request into the database

        const collabJob = await CollabModel.findOne({_id:collab_job_id});
        
        let collabRequestsUsernames = {};

        for(let i = 0;i<collabJob.collabRequests.length;i++){
            collabRequestsUsernames[collabJob.collabRequests[i].username] = 1
        }


        if(collabRequestsUsernames.hasOwnProperty(username)){
            return res.status(400).json({
                result:false,
                msg:"Request was already sent"
            })
        }

        else{
            const collab = await CollabModel.findOneAndUpdate({_id:collab_job_id},{
                $addToSet : {
                    collabRequests: userDataObj
                }
            });
            
            if(!collab){
                return res.status(404).json({
                    result:false,
                    msg:"Problem sending collab request"
                })
            }
            
            return res.status(200).json({
                result:true,
                msg:"Collab request sent"
            })
        }

    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:"There was a problem sending collab request"
        });
    }
}


const getAllCollabRequestForACampJob = async(req,res)=>{
    try{

        let collabID = req.params.id;

        if(collabID == null || collabID == undefined){
            return res.status(400).json({
                result:false,
                msg:"Collab ID is not valid"
            })
        }

        const collab = await CollabModel.find({_id:collabID,collaboratorSearchActive:true});

        if(collab[0].collabRequests.length == 0){
            return res.status(404).json({
                result:false,
                msg:"No collab request found for the camp."
            })
        }

        return res.status(200).json({
            result:true,
            msg:"Collab request for the job fetched",
            data:collab[0].collabRequests
        })

    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:"There was a problem fetching collab request for a jobs in a camp"
        });
    }
}


const acceptUsersRequest = async(req,res)=>{
    try{
        
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        // Saving collab data in the camp

        const txCount = await web3.eth.getTransactionCount(account_address);
        if(!txCount){
            return res.status(500).json({
                result:false,
                msg:'There was a accepting the request'
            })
        }


        let { 
            collab_job_id, 
            camp_address, 
            col_username,
            col_address, 
            collab_title, 
            collab_amount 
        } = req.body;

        // Build the transaction
        
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            to:       contract_address,
            gasLimit: web3.utils.toHex(500000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
            data: contract.methods.collab(col_address,camp_address,collab_title,collab_amount).encodeABI()
        }
    
        // Sign the transaction
        const tx = new Tx(txObject,{chain:42})
        tx.sign(privateKey)
    
        const serializedTx = tx.serialize()
        const raw = '0x' + serializedTx.toString('hex')


        // Broadcast the transaction

        await web3.eth.sendSignedTransaction(raw);


        // Updating the collaboratorSearchActive 

        const collabJob = await CollabModel.findOneAndUpdate({_id:collab_job_id},{collaboratorSearchActive:false});

        if(!collabJob){
            return res.status(500).json({
                msg:"There was a problem updating collaboratorSearchActive status",
                result:false
            })
        }

        // Updating the col's camps_collaborated list

        const userDetails = await UserDetailsModel.findOneAndUpdate({username:col_username},{
            $addToSet : {
                camps_collaborated : collab_job_id
            }
        });

        if(!userDetails){
            return res.status(500).json({
                msg:"There was a problem updating the camps_collaborated list of the col",
                result:false
            })
        }
        
        return res.status(200).json({
            msg:"Collab request accpeted",
            result:true
        })


    }
    catch(err){
        console.log(err)
        res.status(500).json({
            result  :   false,
            msg     :   "There was a problem accepting the request for the user"
        });
    }

}


const rejectCollabRequestForACampJob = async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        let { collab_job_id,col_req_username } = req.body;

        const colJob = await CollabModel.findOneAndUpdate({_id:collab_job_id},
            {
                $pull : {
                    "collabRequests" : { "username" : col_req_username }
                }
            },
            { safe: true, multi:true }
        );

        if(colJob.length == 0){
            return res.status(500).json({
                msg:"There was a problem rejecting the request",
                result:false
            })
        }

        return res.status(200).json({
            msg:"Request rejected",
            result:true
        })

    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result  :   false,
            msg     :   "There was a problem recjecting the collab request"
        });
    }
}


const getCollabAcceptedRequest  =   async(req,res) =>{
    try{

        let campAddress = req.params.campaddress;

        if(campAddress == null || campAddress.length == 0){
            return res.status(404).json({
                msg:"Camp address is not valid",
                result:false
            })
        }

        let collabJobs = await contract.methods.getCollabDetails(campAddress).call();

        if(!collabJobs){
            return res.status(404).json({
                msg:"There was a problem fetching collab job details",
                result:false
            })
        }


        const curatedCollabJobDetails = await Promise.all(collabJobs.map(async(collab)=>{
            let userAuth = await UserAuthModel.findOne({eth_address:collab.colAddress},{email:1,username:1});
            return {...collab,...userAuth['_doc']};
        }));


        return res.status(200).json({       
            msg:"Accepted collabs found",
            result:true,
            curatedCollabJobDetails
        });

    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result  :   false,
            msg     :   "There was a fetching accepted requests"
        });
    }
}    

module.exports = {
    newCollabJobForCamp,
    getAllCollabJobForACamp,
    sendRequestToCollab,
    sendRequestToCollab,
    getAllCollabRequestForACampJob,
    acceptUsersRequest,
    rejectCollabRequestForACampJob,
    getCollabAcceptedRequest
}