const express   = require('express');
const router    = express.Router();
const bcrypt    = require("bcryptjs");
const Web3      = require('web3');
const moment    = require('moment-timezone');
const CryptoJS  = require("crypto-js");
const axios     = require("axios");
const nodemailer = require('nodemailer');

const UserAuthModel     = require("../../../models/userAuthModel");
const CampModel         = require('../../../models/campDetailsMode');
const UserDetailsModel  = require("../../../models/userDetailsModel");

const { body, validationResult } = require("express-validator");
const {generateToken,validateApiSecret,isAuthenticated}=require("../auth/authHelper");
require('dotenv').config();





module.exports = router;