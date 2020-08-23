pragma solidity 0.5.12;

contract coinFlip{

  // uint public balance;

  modifier costs(uint cost){
      require(msg.value >= cost);
      _;
  }

  event betResult(string result);
  event contractFunded(uint amount);

  function getBalance() public view returns(uint){
    return address(this).balance;
  }

  function fundContract() public payable{
    emit contractFunded(getBalance());
  }

  function random() public view returns(uint){
    return now % 2;
  }

  function bet(uint answer) public payable costs(0.1 ether)returns(string memory){
    string memory result = "You lose";

    if(answer == random()){
      msg.sender.transfer(msg.value * 2);
      result = "You win";
    }

    emit betResult(result);
    return result;
  }

}
