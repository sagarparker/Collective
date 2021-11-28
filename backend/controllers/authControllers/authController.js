const bcrypt        =   require("bcryptjs");
const Web3          =   require('web3');
const moment        =   require('moment-timezone');
const CryptoJS      =   require("crypto-js");
const UserAuthModel =   require("../../models/userAuthModel")
const UserDetailsModel      =   require("../../models/userDetailsModel");
const { validationResult }  =   require("express-validator");
const {generateToken}       =   require("../../middleware/authHelper");


require('dotenv').config();

const rpcURL = 'https://ropsten.infura.io/v3/7a0de82adffe468d8f3c1e2183b37c39';

const web3 = new Web3(rpcURL);


const userRegister =  async(req,res) => {
    try{
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(422).json({
          error: errors.array()[0],
          result:false
        });
      }
      
      //Check if the username is within the length bracket
      if(req.body.username.length>50 || req.body.username.length<5){
        return res.status(401).json({
          error:'Username cannot be more than 50 characters and smaller than 5 characters',
          result:false
        });
      }
    
      //Check if the password is smaller than 5
      if(req.body.password.length<5){
        return res.status(401).json({
          error:'Password cannot be smaller than 5 characters',
          result:false
        });
      }
    
            //Hashing password
            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash(req.body.password, salt);


            const ethAccount = await web3.eth.accounts.create();

            if(!ethAccount){
              return res.status(400).json({
                msg:"There was a problem creating ETH account for the user",
                result:false
              });
            }

            // Using AES to encrypt the Ethereum private key

            let ciphertext = CryptoJS.AES.encrypt(ethAccount.privateKey,process.env.master_key).toString();

            //Saving user's auth details

            const userDetails = {
              email:req.body.email,
              username:req.body.username,
              password:hash,
              timestamp:moment().format('MMMM Do YYYY, h:mm:ss a'),
              eth_address:ethAccount.address,
              eth_private_key:ciphertext
            }
            
            const newUser = await UserAuthModel.create(userDetails)

            //Saving user's extra details  

            const userPersonalDetails = {email:req.body.email,username:req.body.username}
  
            const newUserDetails = await UserDetailsModel.create(userPersonalDetails)

            if(newUser && newUserDetails){

              // Generating Token on signup
              let payload = {
                email     : newUserDetails.email,
                username  : newUserDetails.username,
                id        : newUserDetails._id,
                eth_address:ethAccount.address,
                eth_private_key:ciphertext
              };

              const token = generateToken(payload);

              if(token.length>0){
                res.status(200).json({ 
                  result:true,
                  msg: "User registered successfully", 
                  details:newUserDetails,
                  token:token
                });
              }
              else{
                res.status(500).json({
                  msg:"There was a problem creating token for the new user",
                  result:false
                })
              }

            }
            else{
              res.status(400).json(
                { 
                  result:false,
                  msg: "There was a problem creating a new user", 
                });
            }
    }
    catch(err){
      console.log(err);
        if(err.name === 'MongoError' && err.code === 11000){
          console.log(err);
          res.status(401).json({
            result:false,
            msg:"Duplicate field",
            field:err.keyValue
          });
        }
        else{
          res.status(401).json(err);
        }
    }

}



const userLogin = async (req,res)=>{
    try{

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(422).json({
          error: errors.array()[0],
          result:false
        });
      }

      const {email_username,password} = req.body;
    
      const userAuth = await UserAuthModel.find({ $or:[ {email:email_username},{username:email_username} ]});
      if(userAuth.length == 0){
        return res.status(401).json({
          msg:"User doesn't exist",
          result:false
        });
      }
    
      const passwordCheck = await bcrypt.compare(req.body.password,userAuth[0].password);
      if(!passwordCheck){
        return res.status(401).json({
          msg:"Wrong password",
          result:false
        })
      }

      const userDetails = await UserDetailsModel.find({$or:[ {email:email_username},{username:email_username} ]});
      if(!userDetails){
        res.status(404).json({
          msg:"UserDetails not found",
          result:false
        })
      }

      // Create a payload for JWT

      let payload = {
        email: userDetails[0].email,
        username:userDetails[0].username,
        id:userDetails[0]._id,
        eth_address:userAuth[0].eth_address,
        eth_private_key:userAuth[0].eth_private_key
      };

      // Create a JWT token

      const token = generateToken(payload);

      return res.status(200).json({
        email: userDetails[0].email,
        username:userDetails[0].username,
        id:userDetails[0]._id,
        token:token,
        result:true
      });

    }
    catch(err){
      console.log(err);
      res.status(500).json({
        msg:"There was an issue in login",
        result:false
      })
    }

}


const userVerify = async (req,res)=>{
    try{
      const userData = await UserAuthModel.find({ $or:[ {email:req.decoded.email},{username:req.decoded.username}]});
      if(userData.length>0){
        console.log(req.decoded);
        res.status(200).json({
          msg:"User is a valid registered Collective user",
          result:true
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
        msg:"Failed to verify user.",
        result:false,
        err
      });
    }
}

module.exports = {
    userRegister,
    userLogin,
    userVerify
}