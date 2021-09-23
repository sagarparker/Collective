const express             = require('express');
const router              = express.Router();
const userAuthController  = require('../../controllers/authControllers/authController'); 

const { body } = require("express-validator");
const {validateApiSecret,isAuthenticated} = require("../../middleware/authHelper");


// REGISTER new user on collective

router.post('/userRegister',[
  body('email').isEmail(),
  body('email').not().isEmpty(),
  body('username').not().isEmpty(),
  body('password').not().isEmpty()],
  validateApiSecret,
  userAuthController.userRegister
 );


// Login api for Collective

router.post('/userLogin',[
  body('email_username').not().isEmpty(),
  body('password').not().isEmpty()],
  validateApiSecret,
  userAuthController.userLogin
);


//Verify if the user is a registered user with a valid token.

router.post('/verifyUser',
  validateApiSecret,
  isAuthenticated,
  userAuthController.userVerify
);


module.exports = router;
