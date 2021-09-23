const CryptoJS  = require("crypto-js");
const axios     = require("axios");
const nodemailer = require('nodemailer');

const CampModel         = require("../../models/campDetailsModel");
const UserDetailsModel  = require("../../models/userDetailsModel");

const { validationResult } = require("express-validator");
require('dotenv').config();


const getUserDetails = async (req,res)=>{
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
}


const withdrawAmount = async (req,res)=>{
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
          url: 'http://localhost:8080/api/transferCTVbetweenUsers',
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
}


// Support/Help email API

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.email_id,
      pass: process.env.email_password
    },
    tls: {
      rejectUnauthorized: false
    }
});


const supportEmail = async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        let { email_subject,email_message } = req.body;
        let email_sender = req.decoded.email;

        // Using nodemailer to send support email

        const mailOptions = {
          from: email_sender,
          to: 'collectivecfplatform@gmail.com',
          subject: email_sender+" - "+email_subject,
          text: email_sender+" - "+email_message
        };
        
        transporter.sendMail(mailOptions, function(error, info){
          if (error) {
            console.log(error);
            return res.status(500).json({
              msg:"There was a problem sending the email",
              result:false,
              error
            });
          } else {
            return res.status(200).json({
              msg:"Email sent, please wait for the response from our support team",
              result:true
            })
          }
        });

    }
    catch(err){
      console.log(err);
      return res.status(500).json({
        msg:"There was an error sending a message to our team, Please try again.",
        result:false,
      });
    }
}


module.exports = {
    getUserDetails,
    withdrawAmount,
    supportEmail
}