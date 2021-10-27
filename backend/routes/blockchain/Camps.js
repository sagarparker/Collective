const express   =   require('express');
const router    =   express.Router();
const multer    =   require('multer');
const path      =   require('path');
const { v4: uuidv4 }    =   require('uuid');
const { body}           =   require("express-validator");

const campsController    =   require('../../controllers/blockchainControllers/campsController');
const { validateApiSecret,isAuthenticated } =   require("../../middleware/authHelper");

require('dotenv').config();        


// Multer setup for Camp image upload

const storage = multer.diskStorage({
    destination: function(req,file,cb){
        cb(null,(path.join(__dirname,'../../../../CollectiveMedia/camp')));
    },
    filename:function(req,file,cb){
        const file_name = uuidv4() +".jpg";
        cb(null,file_name)
    }
});

const upload = multer({storage:storage});


// CREATE A NEW CROWFUNDING CAMP ON COLLECTIVE

router.post('/createCamp',
    validateApiSecret,
    isAuthenticated,
    upload.single('image'),
    campsController.createCamp
);


// GET CAMP LIST

router.post('/getCampList',
    validateApiSecret,
    isAuthenticated,
    body('sort_by').not().isEmpty(),
    campsController.getCampList
);


// BUY EQUITY IN CAMP

router.post('/buyEquity',
    validateApiSecret,
    isAuthenticated,
    body('camp_address').not().isEmpty(),
    body('amount').not().isEmpty(),
    campsController.buyEquity
);



// GET CAMP DETAILS

router.post('/getCampDetails',
    body('camp_address').not().isEmpty(),
    campsController.getCampDetails
);


// GET CAMP MASTER DETAILS

router.post('/getCampMasterDetails',
    body('camp_address').not().isEmpty(),
    campsController.getCampMasterDetails
);


// GET FUNDING DETAILS

router.post('/getFundingDetails',
    body('camp_address').not().isEmpty(),
    body('angel_address').not().isEmpty(),
    campsController.getFundingDetails
);



// GET NUMBERS OF ANGELS WHO INVESTED IN A CAMP

router.post('/getCampsAngelInvestorsCount',
    body('camp_address').not().isEmpty(),
    campsController.getCampsAngelInvestorsCount
 );


// GET LIST OF ANGEL INVESTORS FOR A CAMP

router.post('/getCampsAngelInvestors',
    body('camp_address').not().isEmpty(),
    campsController.getCampsAngelInvestors
);


// GET CAMPS CREATED BY A USER

router.get('/getCampsCreatedByUser',
    validateApiSecret,
    isAuthenticated,
    campsController.getCampsCreatedByUser
);


// GET CAMPS CREATED BY A USER

router.get('/getCampsInvestedByUser',
    validateApiSecret,
    isAuthenticated,
    campsController.getCampsInvestedByUser
);


// GET COLLAB JOBS OF A USER

router.get('/getUsersCollabs',
    validateApiSecret,
    isAuthenticated,
    campsController.getUsersCollabs
);



// Search for a camp - Search API

router.post('/searchCamp',
    validateApiSecret,
    isAuthenticated,
    [body('camp_name').not().isEmpty()],
    campsController.searchCamp
);


module.exports = router;


