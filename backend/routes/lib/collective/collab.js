const express   = require('express');
const router    = express.Router();
const bcrypt    = require("bcryptjs");
const Web3      = require('web3');
const moment    = require('moment-timezone');
const CryptoJS  = require("crypto-js");
const axios     = require("axios");

const UserAuthModel     = require("../../../models/userAuthModel");
const CampModel         = require('../../../models/campDetailsMode');
const UserDetailsModel  = require("../../../models/userDetailsModel");
const CollabModel       = require("../../../models/collabModel");

const { body, validationResult } = require("express-validator");
const { validateApiSecret,isAuthenticated }=require("../auth/authHelper");
require('dotenv').config();


// Create a new collab job for a camp 

router.post('/newCollabJobForCamp',
    validateApiSecret,
    isAuthenticated,
    [
        body('camp_id').not().isEmpty(),
        body('camp_owner_username').not().isEmpty(),
        body('collab_title').not().isEmpty(),
        body('collab_amount').not().isEmpty(),
        body('collab_description').not().isEmpty()
    ],
    async(req,res)=>{
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
});


// Fetch all the collab jobs for a particular camp

router.get('/getAllCollabJobForACamp/:id',
    validateApiSecret,
    isAuthenticated,
    async(req,res)=>{
        try{

            let campID = req.params.id;

            if(campID == null || campID == undefined){
                return res.status(400).json({
                    result:false,
                    msg:"Camp ID is not valid"
                })
            }

            const collabJobs = await CollabModel.find({campID});

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
});


// Send a request to a camp to join as a collab for a particular position

router.post('/sendRequestToCollab',
    validateApiSecret,
    isAuthenticated,
    [
        body('collab_job_id').not().isEmpty(),
    ],
    async(req,res)=>{
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
});


// Fetch Collab Request for a particular camp


router.get('/getAllCollabRequestForACamp/:id',
    validateApiSecret,
    isAuthenticated,
    async(req,res)=>{
        try{

            let collabID = req.params.id;

            if(collabID == null || collabID == undefined){
                return res.status(400).json({
                    result:false,
                    msg:"Collab ID is not valid"
                })
            }

            const collab = await CollabModel.find({_id:collabID,collaboratorSearchActive:true});
            console.log(collab);

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
});

// accept a re

router.post('/acceptUsersRequest',async(req,res)=>{

})




module.exports = router;