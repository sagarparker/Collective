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
    camps_owned             :   [{
                                    type:mongoose.Schema.Types.ObjectId,
                                    ref:'CampDetails'
                                }],
    camps_invested          :   [{
                                    type:mongoose.Schema.Types.ObjectId,
                                    ref:'CampDetails'
                                }],
    camps_collaborated      :   [{
                                    type:mongoose.Schema.Types.ObjectId,
                                    ref:'Collab'
                                }],
});

module.exports = mongoose.model("UserDetails",userDetailsSchema);
