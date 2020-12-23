import "./ownable.sol";
// import "./provableRN.sol";
import "./provableAPI.sol";
pragma solidity 0.5.12;

// contract coinFlip is ownable, provableRN{
// contract coinFlip is ownable{
contract coinFlip is ownable, usingProvable{

  // uint256 constant public moduloRN = 2;
  // bool boolCallbackFunction = true;

  modifier costs(uint256 cost){
      require(msg.value >= cost);
      _;
  }

  event betResult(bytes32 queryID, string _result, uint256 _value);
  event contractFunded(string, uint256);
  event fundsWithdrawn(string, uint256);
  // event prize(uint amount);
  event testBlocknumber(uint256);

  struct infoBet {
    bytes32 queryID;
    address player;
    uint256 betAmount;
    uint256 guessNumber;
    uint256 randomNumber;
    uint256 blockNumber;
    bool setRandomNumber;
  }

  mapping (bytes32 => infoBet) private historyBets;
  mapping (address => bytes32[]) private playersqueryIDs;
  address[] public players;

  function getBalance() public view returns(uint256){
    return address(this).balance;
  }

  function getQueryIDs(address player) public view returns(bytes32[] memory) {
    return playersqueryIDs[player];
  }

  function getBetInfo(bytes32 queryID) public view returns(address player,
    uint256 betAmount, uint256 guessNumber, uint256 randomNumber,
    uint256 blockNumber, bool setRandomNumber) {
    return (historyBets[queryID].player,
      historyBets[queryID].betAmount,
      historyBets[queryID].guessNumber,
      historyBets[queryID].randomNumber,
      historyBets[queryID].blockNumber,
      historyBets[queryID].setRandomNumber
    );
  }

  function getPlayer(uint256 index) public view returns(address){
    return players[index];
  }

  function fundContract() public payable{
    emit contractFunded("Contract funded", msg.value);
  }

  function withdrawAll() public onlyOwner{
      uint256 toTransfer = getBalance();
      msg.sender.transfer(toTransfer);
      emit fundsWithdrawn('Funds withdrawn', toTransfer);
  }

  function makeBet(uint256 guessNumber) public payable costs(0.001 ether){
    bytes32 queryID = provable_newRandomDSQuery(EXECUTION_DELAY,NUMBER_RANDOM_BYTES,CALLBACK_GAS_LIMIT);
    emit logNewProvableQuery(queryID, "Query for random number has been sent. Waiting for response.");

    address player = msg.sender;
    uint256 betAmount = msg.value;

    // Storing information for settling the bet when random number is returned
    infoBet memory newBet;
    newBet.queryID = queryID;
    newBet.player = player;
    newBet.betAmount = betAmount;
    newBet.guessNumber = guessNumber;
    newBet.blockNumber = block.number;
    newBet.setRandomNumber = false;
    historyBets[queryID] = newBet;

    // Storing information regarding the bets of each player.
    if(playersqueryIDs[player].length == 0){
      // bytes32[] storage queryIDs;
      // queryIDs.push(queryID);
      // playersqueryIDs[player] = queryIDs;
      playersqueryIDs[player] = [queryID];
      players.push(player);
    }else{
      playersqueryIDs[player].push(queryID);
    }

    // // Code for test random function without using oracle
    // uint256 randomNumber = historyBets[queryID].randomNumber;
    // settleBet(queryID, randomNumber);
  }



  // // Function that will be executed after callback by provable oracle.
  // function callbackFunction(uint256 randomNumber, bytes32 queryID) public {
  //   address payable player = address(uint160(historyBets[queryID].player));
  //   uint256 betAmount = historyBets[queryID].betAmount;
  //   uint256 guessNumber = historyBets[queryID].guessNumber;
  //   string memory result = "You lose";
  //   historyBets[queryID].randomNumber = randomNumber;
  //
  //   if(guessNumber == randomNumber){
  //     result = "You win";
  //     betAmount = betAmount * 2;
  //     player.transfer(betAmount);
  //   }
  //   emit betResult(queryID, result, betAmount);
  // }


  uint256 constant NUMBER_RANDOM_BYTES = 1;
  uint256 EXECUTION_DELAY = 0;
  uint256 CALLBACK_GAS_LIMIT = 200000;
  // bool boolCallbackFunction = false;
  uint256 constant moduloRN = 2; // Modula for determining range of the random number
  // bytes32 public lastqueryID;

  event logNewProvableQuery(bytes32 queryID, string description);
  // event generatedRandomNumber(string text, uint256 randomNumber);

  // constructor() public{
  //   generateRandomNumber();
  // }

  // function callbackFunction(uint256 randomNumber, bytes32 queryID, string memory _result, bytes memory _proof) public {}

  function __callback(bytes32 queryID, string memory _result) public {
    require(msg.sender == provable_cbAddress());

    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % moduloRN;
    historyBets[queryID].randomNumber = randomNumber;
    historyBets[queryID].setRandomNumber = true;
    // emit generatedRandomNumber("RandomNumber: ", randomNumber);

    settleBet(queryID, randomNumber); //Uncomment for provable RN
  }

  // function generateRandomNumber() payable public returns(bytes32){
  //   // bytes32 queryID = testRandomNumber();
  //   bytes32 queryID = provable_newRandomDSQuery(EXECUTION_DELAY,NUMBER_RANDOM_BYTES,
  //     CALLBACK_GAS_LIMIT);
  //   emit logNewProvableQuery(queryID, "Query for random number has been sent. Waiting for response.");
  //   // lastqueryID = queryID;
  //   return queryID;
  // }

  function settleBet(bytes32 queryID, uint256 randomNumber) internal {
    address payable player = address(uint160(historyBets[queryID].player));
    uint256 betAmount = historyBets[queryID].betAmount;
    uint256 guessNumber = historyBets[queryID].guessNumber;
    string memory result = "You lose";

    if(guessNumber == randomNumber){
      result = "You win";
      betAmount = betAmount * 2;
      player.transfer(betAmount);
    }
    emit betResult(queryID, result, betAmount);
    emit testBlocknumber(block.number-1);
  }

  // function testRandomNumber() public returns(bytes32){
  //   bytes32 queryID = bytes32(keccak256(abi.encodePacked(block.number)));
  //   __callback(queryID, "1", bytes("test"));
  //   return queryID;
  // }
  // function random() public view returns(uint){
  //   return now % 2;
  // }
  //
  // function bet(uint answer) public payable costs(0.001 ether)returns(string memory){
  //   string memory result = "You lose";
  //   uint amount = msg.value;
  //
  //   if(answer == random()){
  //     result = "You win";
  //     amount = amount * 2;
  //     msg.sender.transfer(amount);
  //   }
  //
  //   emit betResult(result, amount);
  //   return result;
  // }
}
