pragma solidity 0.5.12;

contract coinFlip{

  // uint public balance;

  modifier costs(uint cost){
      require(msg.value >= cost);
      _;
  }

  event betResult(string _result, uint _value);
  event contractFunded(uint _value);
  // event prize(uint amount);


  // uint public balance;

  function getBalance() public view returns(uint){
    return address(this).balance;
  }

  function fundContract() public payable{
    // balance += msg.value;
    emit contractFunded(getBalance());
  }

  function random() public view returns(uint){
    return now % 2;
  }

  function bet(uint answer) public payable costs(0.1 ether)returns(string memory){
    string memory result = "You lose";
    uint amount = msg.value;

    if(answer == random()){
      result = "You win";
      amount = amount * 2;
      msg.sender.transfer(amount);
    }

    emit betResult(result, amount);
    return result;
  }

}
