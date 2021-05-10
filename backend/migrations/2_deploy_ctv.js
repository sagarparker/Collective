var CollectiveToken = artifacts.require("./CollectiveToken.sol");

module.exports = function(deployer){
    deployer.deploy(CollectiveToken);
}