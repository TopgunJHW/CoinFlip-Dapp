const coinFlip = artifacts.require("coinFlip");
const truffleAssert = require("truffle-assertions");

let instance;

// Runs this code once before all the tests
before(async function(){
  instance = await coinFlip.deployed();
});

contract("coinFlip", async function(){
  it("Should fund the contract correctly", async function(){
    let balanceBefore = await web3.eth.getBalance(instance.address);
    let fundAmount = {value: web3.utils.toWei("1", "ether")};
    await instance.fundContract(fundAmount);
    let balanceAfter = await web3.eth.getBalance(instance.address);

    assert(parseInt(balanceBefore) + parseInt(fundAmount['value']) == parseInt(balanceAfter), "Funding the contract has failed");
  });
  it("Should not accept zero bet", async function(){
    await truffleAssert.fails(instance.bet(1), truffleAssert.ErrorType.REVERT);
  });
  it("Should not accept too low bet", async function(){
    await truffleAssert.fails(instance.bet(1, {value: web3.utils.toWei("0.001", "ether")}), truffleAssert.ErrorType.REVERT);
  });
  // it("Should be random", async function(){
  //   let instance = await coinFlip.deployed();
  //   let even = 0;
  //   let uneven = 0;
  //   for (var i = 0; i < 100; i++) {
  //     if (instance.random() == 0){
  //       even += 1;
  //     }
  //     else {
  //       uneven += 1
  //     }
  //   };
  //   assert(0,"even:" + even + ". Uneven: " + uneven)
  // });
});
