var mongoose    =  require("mongoose");

var campDetailsSchema = new mongoose.Schema({
name            :   {
                        type:String,
                        default:'NA',
                        required:true,
                        unique:true,
                        index:true
                    },
owner           :   {
                        type:String,
                        default:'NA',
                        required:true
                    },
createdOn       :   {
                        type:String,
                        default:'NA',
                        required:true
                    },
target          :   {
                        type:String,
                        default:'NA',
                        required:true
                    },
equity          :   {
                        type:String,
                        default:'NA',
                        required:true
                    }
});

module.exports = mongoose.model("CampDetails",campDetailsSchema);
