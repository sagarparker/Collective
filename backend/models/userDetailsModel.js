var mongoose    =  require("mongoose");

var userDetailsSchema = new mongoose.Schema({
email                   :   {
                                type:String,
                                unique:true
                            },
username                :   {
                                type:String,
                                unique:true 
                            },        
profile_picture         :   {
                                type:String,
                                default:'NA'
                            },        
});

module.exports = mongoose.model("UserDetails",userDetailsSchema);
