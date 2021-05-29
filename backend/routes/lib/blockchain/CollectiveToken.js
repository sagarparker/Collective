const express   =   require('express');
const router    =   express.Router();
const Tx        =   require('ethereumjs-tx').Transaction;
const Web3      =   require('web3');
const { body, validationResult } = require("express-validator");
const { validateApiSecret,isAuthenticated }   =   require("../auth/authHelper");
require('dotenv').config();


///////////////////////////
//Web3 and contract setup
///////////////////////////

const rpcURL = 'https://kovan.infura.io/v3/7a0de82adffe468d8f3c1e2183b37c39';

const web3 = new Web3(rpcURL);

const CollectiveToken = require('../../../build/contracts/CollectiveToken.json');

const contract_address = process.env.ctv_contract_address;

const abi = CollectiveToken.abi;

const contract = new web3.eth.Contract(abi,contract_address)


//////////////////////
// Account addresses
/////////////////////

//Main account with which contract is deployed

const account_address_1 = process.env.account_1;

// // Testing accounts

// const account_address_2 = process.env.account_2;

// const account_address_3 = process.env.account_3;

// const account_address_4 = process.env.account_4;

// const account_address_5 = process.env.account_5;

// // Trial account 

// const account_address_6 = process.env.trial_account_1;

// const account_address_7 = process.env.trial_account_2;



//////////////////
/// Private keys
/////////////////

// Main private key - token generation

const privateKey1 = Buffer.from(process.env.privateKey_1,'hex');

// // Testing private key

// const privateKey2 = Buffer.from(process.env.privatekey_2,'hex');

// const privateKey3 = Buffer.from(process.env.privatekey_3,'hex');

// const privateKey4 = Buffer.from(process.env.privatekey_4,'hex');

// const privateKey5 = Buffer.from(process.env.privatekey_5,'hex');

// // Trial accout private key 

// const privateKey6 = Buffer.from(process.env.trial_privatekey_1,'hex');

// const privateKey7 = Buffer.from(process.env.trial_privatekey_2,'hex');



// Get users account balance

router.get('/getAccountBalance',
    validateApiSecret,
    body('account_address').not().isEmpty(),
    async(req,res)=>{
        try{

             //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const ctvBalance = await contract.methods.balanceOf(req.body.account_address).call();
            const ethBalance = await web3.eth.getBalance(req.body.account_address);

            if(!ctvBalance || !ethBalance){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the users account balance'
                })
            }

            return res.status(200).json({
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
                msg:'There was a problem fetching the users account balance'
            })
        }
});


router.get('/getUsersAccountBalance',
    validateApiSecret,
    isAuthenticated,
    async(req,res)=>{
        try{

            const ctvBalance = await contract.methods.balanceOf(req.decoded.eth_address).call();
            const ethBalance = await web3.eth.getBalance(req.decoded.eth_address);

            if(!ctvBalance || !ethBalance){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the users account balance'
                })
            }

            return res.status(200).json({
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
                msg:'There was a problem fetching the users account balance'
            })
        }
});



// Sending ETH to users

router.post('/transferETH',
    [body('transfer_address').not().isEmpty(),
    body('amount').not().isEmpty()],
    async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const transfer_address = req.body.transfer_address;
        const amount    =   req.body.amount.toString();

        const txCount = await web3.eth.getTransactionCount(account_address_1);
        if(!txCount){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring ETH'
            })
        }
        // Build the transaction
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            to:       transfer_address,
            value:    web3.utils.toHex(web3.utils.toWei(amount, 'gwei')),
            gasLimit: web3.utils.toHex(21000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
        }
    
        // Sign the transaction
        const tx = new Tx(txObject,{chain:42})
        tx.sign(privateKey1)
    
        const serializedTx = tx.serialize()
        const raw = '0x' + serializedTx.toString('hex')
    
        // Broadcast the transaction
        const sendTransaction = await web3.eth.sendSignedTransaction(raw);
        if(!sendTransaction){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring ETH'
            })
        }

        return res.status(200).json({
            result:true,
            msg:`ETH transfered : ${amount} ETH`
        })

      
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem transferring ETH'
        })
    }
});


// Sending CTV - Collective token to users

router.post('/transferCTV',
    [body('transfer_address').not().isEmpty(),
    body('amount').not().isEmpty()],
    async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const transfer_address = req.body.transfer_address;
        const amount    =   req.body.amount;

        const txCount = await web3.eth.getTransactionCount(account_address_1);
        if(!txCount){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring CTV'
            })
        }
        // Build the transaction
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            to:       contract_address,
            gasLimit: web3.utils.toHex(500000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
            data: contract.methods.transfer(transfer_address,amount).encodeABI()
        }
    
        // Sign the transaction
        const tx = new Tx(txObject,{chain:42})
        tx.sign(privateKey1)
    
        const serializedTx = tx.serialize()
        const raw = '0x' + serializedTx.toString('hex')
    
        // Broadcast the transaction
        const sendTransaction = await web3.eth.sendSignedTransaction(raw);
        if(!sendTransaction){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring CTV'
            })
        }

        return res.status(200).json({
            result:true,
            msg:`CTV transfered : ${amount} CTV`
        })

      
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem transferring CTV'
        })
    }
});


// Transfer CTV to use - with AUTH

router.post('/transferCTVToUser',
    validateApiSecret,
    isAuthenticated,
    body('amount').not().isEmpty(),
    async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const transfer_address = req.decoded.eth_address;
        const amount    =   req.body.amount;

        const txCount = await web3.eth.getTransactionCount(account_address_1);
        if(!txCount){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring CTV'
            })
        }
        // Build the transaction
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            to:       contract_address,
            gasLimit: web3.utils.toHex(500000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
            data: contract.methods.transfer(transfer_address,amount).encodeABI()
        }
    
        // Sign the transaction
        const tx = new Tx(txObject,{chain:42})
        tx.sign(privateKey1)
    
        const serializedTx = tx.serialize()
        const raw = '0x' + serializedTx.toString('hex')
    
        // Broadcast the transaction
        const sendTransaction = await web3.eth.sendSignedTransaction(raw);
        if(!sendTransaction){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring CTV'
            })
        }

        return res.status(200).json({
            result:true,
            msg:`CTV transfered : ${amount} CTV`
        })

      
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem transferring CTV'
        })
    }
});


// Get the allowance for a account;

router.post('/getAllowance',
    [body('owner_address').not().isEmpty(),
    body('spender_address').not().isEmpty()],
    async(req,res)=>{
        try{
             //Input field validation
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(422).json({
                    error: errors.array()[0],result:false   
                });
            }

            const owner_address     =   req.body.owner_address;
            const spender_address   =   req.body.spender_address;

            const allowance = await contract.methods.allowance(owner_address,spender_address).call()

            if(!allowance){
                return res.status(500).json({
                    result:false,
                    msg:'There was a problem fetching the account allowance.'
                })
            }

            return res.status(200).json({
                result:true,
                msg:'Allowance for account fetched',
                allowance:allowance
            });
            
        }
        catch(err){
            console.log(err);
            res.status(500).json({
                result:false,
                msg:'There was a problem fetching the account allowance.'
            })
        }
});


// Transfer CTV between user accounts

/// How the API works

// 1. Start with sending required ETH (gas) from the master account to CTV owner account
// 2. Approve the transaction amount
// 3. Send the amount to the transfer address from the CTV owner address

router.post('/transferCTVbetweenUsers',
    [body('owner_address').not().isEmpty(),
    body('owner_private_key').not().isEmpty(),
    body('transfer_address').not().isEmpty(),
    body('amount').not().isEmpty()],
    async(req,res)=>{
    try{
        //Input field validation
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({
                error: errors.array()[0],result:false   
            });
        }

        const owner_address     =   req.body.owner_address;
        const owner_private_key =   Buffer.from(req.body.owner_private_key,'hex');
        const transfer_address  =   req.body.transfer_address;
        const amount            =   req.body.amount;




        ///////////////////////////////////////////////////////////////
        // Transferring ETH(gas) required for the transaction to owner 
        ///////////////////////////////////////////////////////////////

        const txCount = await web3.eth.getTransactionCount(account_address_1);
        if(!txCount){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring ETH - gas for the transaction'
            })
        }
        // Build the transaction
        const txObject1 = {
            nonce:    web3.utils.toHex(txCount),
            to:       owner_address,
            value:    web3.utils.toHex(web3.utils.toWei('200000', 'gwei')),
            gasLimit: web3.utils.toHex(21000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
        }
    
        // Sign the transaction
        const tx1 = new Tx(txObject1,{chain:42})
        tx1.sign(privateKey1)
    
        const serializedTx1 = tx1.serialize()
        const raw1 = '0x' + serializedTx1.toString('hex')
    
        // Broadcast the transaction
        const sendTransaction = await web3.eth.sendSignedTransaction(raw1);
        if(!sendTransaction){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring ETH - gas for the transaction'
            })
        }
        console.log('\nETH transfered for the transaction');





        //////////////////////////////////////////////////////////////
        // Getting approval for the transaction
        //////////////////////////////////////////////////////////////
    
        const ownertxCount = await web3.eth.getTransactionCount(owner_address);

        // Build the transaction
        const txObject2 = {
        nonce:    web3.utils.toHex(ownertxCount),
        to:       contract_address,
        gasLimit: web3.utils.toHex(50000),
        gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
        data: contract.methods.increaseAllowance(owner_address,amount).encodeABI()
        }
    
        // Sign the transaction
        const tx2 = new Tx(txObject2,{chain:42})
        tx2.sign(owner_private_key)
    
        const serializedTx2 = tx2.serialize()
        const raw2 = '0x' + serializedTx2.toString('hex')
    
        // Broadcast the transaction
        const approvalHash = await web3.eth.sendSignedTransaction(raw2);

        if(!approvalHash){
            return res.status(500).json({
                result:false,
                msg:'There was a problem getting approval for transaction'
            })
        }
        
        console.log("\nTransfer approved");



        /////////////////////////////////
        // Transfering CTV between users
        /////////////////////////////////


        const ownertxCountUpdated = await  web3.eth.getTransactionCount(owner_address);

     
        // Build the transaction
        const txObject3 = {  
            nonce:    web3.utils.toHex(ownertxCountUpdated),
            to:       contract_address,
            gasLimit: web3.utils.toHex(100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('1', 'gwei')),
            data: contract.methods.transferFrom(owner_address,transfer_address,amount).encodeABI()
        }

        
        // Sign the transaction2
        const tx3 = new Tx(txObject3,{chain:42})
        tx3.sign(owner_private_key)
        
        const serializedTx3 = tx3.serialize()
        const raw3 = '0x' + serializedTx3.toString('hex')
        
        // Broadcast the transaction
        const finalTransactionHash = await web3.eth.sendSignedTransaction(raw3);
        if(!finalTransactionHash){
            return res.status(500).json({
                result:false,
                msg:'There was a problem transferring CTV between users'
            })
        }

        console.log(`\nCTV transfered between users : ${amount} CTV`);
        return res.status(200).json({
            result:true,
            msg:`CTV transfered between users : ${amount} CTV` 
        })      
    }
    catch(err){
        console.log(err);
        res.status(500).json({
            result:false,
            msg:'There was a problem transferring CTV between the users.'
        })
    }
});





module.exports = router;