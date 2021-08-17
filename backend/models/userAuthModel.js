var mongoose    =  require("mongoose");

var userAuthSchema = new  mongoose.Schema({
email                   :   {
                                type:String,
                                unique:true
                            },
username                :   {
                                type:String,
                                unique:true
                            },
password                :   {   
                                type:String,
                                required:true
                            },
timestamp               :   {   
                                type:String,
                                required:true
                            },
eth_address             :   {
                                type:String,
                                required:true
                            },
eth_private_key         :   {
                                type:String,
                                required:true
                            }
});

module.exports = mongoose.model("UserAuth",userAuthSchema);
