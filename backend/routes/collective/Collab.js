const express   =   require('express');
const router    =   express.Router();

const { body }  =   require("express-validator");
const { validateApiSecret,isAuthenticated } =   require("../../middleware/authHelper");

const collabController  =   require('../../controllers/collectiveControllers/collabController');

require('dotenv').config();



// Create a new collab job for a camp 

router.post('/newCollabJobForCamp',
    validateApiSecret,
    isAuthenticated,
    [
        body('camp_id').not().isEmpty(),
        body('camp_owner_username').not().isEmpty(),
        body('collab_title').not().isEmpty(),
        body('collab_amount').not().isEmpty(),
        body('collab_description').not().isEmpty()
    ],
    collabController.newCollabJobForCamp
);


// Fetch all the collab jobs for a particular camp

router.get('/getAllCollabJobForACamp/:id',
    validateApiSecret,
    isAuthenticated,
    collabController.getAllCollabJobForACamp
);


// Send a request to a camp to join as a collab for a particular position

router.post('/sendRequestToCollab',
    validateApiSecret,
    isAuthenticated,
    [body('collab_job_id').not().isEmpty()],
    collabController.sendRequestToCollab
);


// Fetch Collab Request for a particular camp


router.get('/getAllCollabRequestForACampJob/:id',
    validateApiSecret,
    isAuthenticated,
    collabController.getAllCollabRequestForACampJob
);



// Accept a request for a collab job

router.post('/acceptUsersRequest',
    validateApiSecret,
    isAuthenticated,
    [   body('collab_job_id').not().isEmpty(),
        body('camp_address').not().isEmpty(),
        body('col_username').not().isEmpty(),
        body('col_address').not().isEmpty(),
        body('collab_title').not().isEmpty(),
        body('collab_amount').not().isEmpty(),
    ],
    collabController.acceptUsersRequest
);



// Reject a collab request for a collab

router.put('/rejectCollabRequestForACampJob',    
    validateApiSecret,
    isAuthenticated,
    [
        body('collab_job_id').not().isEmpty(),
        body('col_req_username').not().isEmpty(),
    ],
    collabController.rejectCollabRequestForACampJob
);



// Get camps accepted collabs

router.get('/getCollabAcceptedRequest/:campaddress',    
    validateApiSecret,
    isAuthenticated,
    collabController.getCollabAcceptedRequest
);



module.exports = router;