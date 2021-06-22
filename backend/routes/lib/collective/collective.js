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

const { body, validationResult } = require("express-validator");
const {generateToken,validateApiSecret,isAuthenticated}=require("../auth/authHelper");
require('dotenv').config();


// Fetch user data

router.post('/getUserDetails',
  validateApiSecret,
  isAuthenticated,
  async (req,res)=>{
    try{
      
      const userData = await UserDetailsModel.find({username:req.decoded.username});
      if(userData.length>0){
        res.status(200).json({
          msg:"User is a valid registered Collective user",
          result:true,
          userData:userData[0],
          userAuthData:req.decoded
        })
      }
      else{
        res.status(404).json({
          error:"User doesn't exist",
          result:false
        })
      }
    }catch(err){
      return res.status(500).json({
        msg:"Failed to fetch user data.",
        result:false,
        err
      });
    }
});


// Withdraw camp amount raised

router.post('/withdrawAmount',
  validateApiSecret,
  isAuthenticated,
  [body('owner_address').not().isEmpty(),
  body('owner_private_key').not().isEmpty(),
  body('amount').not().isEmpty()],
  async (req,res)=>{
    try{

        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const owner_address     =   req.body.owner_address;
        const owner_private_key =   req.body.owner_private_key;
        const transfer_address  =   req.decoded.eth_address;
        const amount            =   req.body.amount;

        const buyer_private_key =   owner_private_key;
        let bytes  = CryptoJS.AES.decrypt(buyer_private_key, process.env.master_key);
        let bytes_key = bytes.toString(CryptoJS.enc.Utf8).slice(2);
        let original_private_key = Buffer.from(bytes_key,'hex');



        var data = JSON.stringify({
          "owner_address": owner_address,
          "owner_private_key": original_private_key,
          "transfer_address": transfer_address,
          "amount": amount
        });
        
        var config = {
          method: 'post',
          url: 'http://3.15.217.59:8080/api/transferCTVbetweenUsers',
          headers: { 
            'Content-Type': 'application/json'
          },
          data : data
        };
        
        axios(config)
        .then(async function (response) {
          const userData = await CampModel.findOneAndUpdate({address:owner_address},{amountWithdrawn:true});
          if(userData){
            res.status(200).json({
              msg:"Amount withdrawal successful",
              result:true,
            })
          }
          else{
            res.status(404).json({
              error:"Camp doesnt exits!",
              result:false
            })
          }
        })
        .catch(function (error) {
          console.log(error);
          return res.status(500).json({
            msg:"Failed to withdraw amount!",
            result:false,
          });
        });
      

    }catch(err){
      console.log(err);
      return res.status(500).json({
        msg:"Failed to withdraw amount!",
        result:false,
      });
    }
});





module.exports = router;