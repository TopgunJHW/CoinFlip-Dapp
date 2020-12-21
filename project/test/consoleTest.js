https://www.trufflesuite.com/tutorials/debugging-a-smart-contract
truffle develop
truffle develop --log
truffle compile
truffle compile --reset
truffle migrate


// Get balance of contract in eth
coinFlip.deployed().then(function(instance){return instance.getBalance.call();}).then(function(value){return web3.utils.fromWei(value.toString(), 'ether')});
coinFlip.deployed().then(function(instance){
  return instance.getBalance.call();}).then(function(value){
    return web3.utils.fromWei(value.toString(), 'ether')});

instance = await coinFlip.deployed()
instance.makeBet(0, {value: web3.utils.toWei('1', 'ether'), from:accounts[0]})
