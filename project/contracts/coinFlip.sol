import "./Ownable.sol";
import "./provableRN.sol";
pragma solidity 0.5.12;

contract coinFlip is Ownable, provableRN{

  modifier costs(uint cost){
      require(msg.value >= cost);
      _;
  }

  event betResult(string _result, uint _value);
  event contractFunded(uint _value);
  // event prize(uint amount);

  function getBalance() public view returns(uint){
    return address(this).balance;
  }

  function fundContract() public payable{
    // balance += msg.value;
    emit contractFunded(getBalance());
  }

  function withdrawAll() public onlyOwner returns(uint) {
      uint toTransfer = getBalance();
      msg.sender.transfer(toTransfer);
      return toTransfer;
  }

  function random() public view returns(uint){
    return now % 2;
  }

  function bet(uint answer) public payable costs(0.001 ether)returns(string memory){
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

  // Function that will be executed after callback by provable oracle.
  function callbackFunction(uint256 randomNumber, bytes32 queryId, string memory _result, bytes memory _proof) public {
    
  }

}
