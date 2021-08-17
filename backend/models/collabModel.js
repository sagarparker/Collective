var mongoose = require('mongoose');

var collabSchema = new mongoose.Schema({
    
    campID              :       {
                                    type:String,
                                    required:true,
                                    default:'NA'
                                },
    collabTitle         :       {
                                    type:String,
                                    default:'NA'
                                },
    collabCtvAmount     :       {
                                    type:String,
                                    default:'NA'
                                },
    collabDescription   :       {
                                    type:Array,
                                    default:[]
                                },
    collabRequests      :       [{
                                    username    :   String,
                                    address     :   String,
                                    acceppted   :   {
                                                        type    :   Boolean,
                                                        default :   false
                                                    } 
                                }]
}); 

module.exports = mongoose.model("Collab",collabSchema)
