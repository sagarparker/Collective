const express   = require('express');
const router    = express.Router();

const { body }  = require("express-validator");
const { validateApiSecret,isAuthenticated }=require("../../middleware/authHelper");
require('dotenv').config();

const collectiveController = require('../../controllers/collectiveControllers/collectiveController');


// Fetch user data

router.post('/getUserDetails',
  validateApiSecret,
  isAuthenticated,
  collectiveController.getUserDetails
);


// Withdraw camp amount raised

router.post('/withdrawAmount',
  validateApiSecret,
  isAuthenticated,
  [body('owner_address').not().isEmpty(),
  body('owner_private_key').not().isEmpty(),
  body('amount').not().isEmpty()],
  collectiveController.withdrawAmount
);



router.post('/supportEmail',
  validateApiSecret,
  isAuthenticated,
  [ 
    body('email_subject').not().isEmpty(),
    body('email_message').not().isEmpty()
  ],
  collectiveController.supportEmail
);




module.exports = router;