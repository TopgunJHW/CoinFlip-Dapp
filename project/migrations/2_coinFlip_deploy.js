const coinFlip = artifacts.require("coinFlip");
//
module.exports = function(deployer, network, accounts) {
  deployer.deploy(coinFlip).then(function(instance){
    instance.fundContract({value: web3.utils.toWei("0.01", "ether")}).then(function(){
      console.log("Initial balance set!")
    }).catch(function(err){
      console.log("Initial balance not set! Error: ");
    });
  }).catch(function(err){
    console.log("Deploy failed! Error: " + err)
  });
};
