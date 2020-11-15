const randomCall = artifacts.require("randomCall");

module.exports = function(deployer){
  deployer.deploy(randomCall);
};
