const express   = require('express');
const router    = express.Router();
const bcrypt    = require("bcryptjs");
const Web3      = require('web3');
const moment    = require('moment-timezone');
const CryptoJS  = require("crypto-js");
const UserAuthModel = require("../../../models/userAuthModel");
const UserDetailsModel = require("../../../models/userDetailsModel");
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


module.exports = router;