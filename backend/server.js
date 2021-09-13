const app       = require("./routes/router");
const http      = require("http");
const mongoose  = require("mongoose");


// MongoDB connection

mongoose.connect("mongodb+srv://sagarparker:hihellohi8@sagarparker.ccy2e.mongodb.net/collectiveDB?retryWrites=true&w=majority",
{ useNewUrlParser: true,
  useCreateIndex:true,
  useFindAndModify:false,
  useUnifiedTopology: true
}).then(() => {
    console.log("Connected to MongoDB");
}).catch(err => {
    console.log("Error connecting to Collective Database",err.message);
});



// Server setup

const server = http.createServer(app);

server.listen(8080, () => {
  console.log("Collective server started on port 8080");
});
