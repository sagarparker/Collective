const express   =   require('express');
const router    =   express.Router();
const { body } = require("express-validator");
const { validateApiSecret,isAuthenticated }   =   require("../../middleware/authHelper");
require('dotenv').config();

const collectiveTokenController = require('../../controllers/blockchainControllers/collectiveTokenController');


// Get users account balance

router.get('/getAccountBalance',
    validateApiSecret,
    body('account_address').not().isEmpty(),
    collectiveTokenController.getAccountBalance
);


// // Get users account balance

router.get('/getUsersAccountBalance',
    validateApiSecret,
    isAuthenticated,
    collectiveTokenController.getUsersAccountBalance
);


// Sending ETH to users

router.post('/transferETH',
    [body('transfer_address').not().isEmpty(),
    body('amount').not().isEmpty()],
    collectiveTokenController.transferETH
);


// Sending CTV - Collective token to users

router.post('/transferCTV',
    [body('transfer_address').not().isEmpty(),
    body('amount').not().isEmpty()],
    collectiveTokenController.transferCTV
);


// Transfer CTV to use - with AUTH

router.post('/transferCTVToUser',
    validateApiSecret,
    isAuthenticated,
    body('amount').not().isEmpty(),
    collectiveTokenController.transferCTVToUser
);


// Get the allowance for a account;

router.post('/getAllowance',
    [body('owner_address').not().isEmpty(),
    body('spender_address').not().isEmpty()],
    collectiveTokenController.getAllowance
);


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
    collectiveTokenController.transferCTVbetweenUsers
);


module.exports = router;