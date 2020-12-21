import "./ownable.sol";
// import "./provableRN.sol";
// import "./provableAPI.sol";
pragma solidity 0.5.12;

// contract coinFlip is ownable, provableRN{
contract coinFlip is ownable{
// contract coinFlip is ownable, usingProvable{

  // uint256 public moduloRN = 2;
  // bool boolCallbackFunction = true;

  modifier costs(uint256 cost){
      require(msg.value >= cost);
      _;
  }

  event betResult(bytes32 queryId, string _result, uint256 _value);
  event contractFunded(uint256 _value);
  // event prize(uint amount);

  struct infoBet {
    bytes32 queryId;
    address player;
    uint256 betAmount;
    uint256 guessNumber;
    uint256 randomNumber;
  }

  mapping (bytes32 => infoBet) private historyBets;
  mapping (address => bytes32[]) private playersQueryIds;
  address[] public players;

  function getBalance() public view returns(uint256){
    return address(this).balance;
  }

  function fundContract() public payable{
    // balance += msg.value;
    emit contractFunded(getBalance());
  }

  function withdrawAll() public onlyOwner returns(uint256) {
      uint256 toTransfer = getBalance();
      msg.sender.transfer(toTransfer);
      return toTransfer;
  }

  function makeBet(uint256 guessNumber) public payable costs(0.001 ether){
    bytes32 queryId = generateRandomNumber();
    address player = msg.sender;
    uint256 betAmount = msg.value;

    // Storing information for settling the bet when random number is returned
    infoBet memory newBet;
    newBet.queryId = queryId;
    newBet.player = player;
    newBet.betAmount = betAmount;
    newBet.guessNumber = guessNumber;
    historyBets[queryId] = newBet;

    // Storing information regarding the bets of each player.
    if(playersQueryIds[player].length == 0){
      // bytes32[] storage queryIds;
      // queryIds.push(queryId);
      // playersQueryIds[player] = queryIds;
      playersQueryIds[player] = [queryId];
      players.push(player);
    }else{
      playersQueryIds[player].push(queryId);
    }


    // Code for test random function without using oracle
    uint256 randomNumber = historyBets[queryId].randomNumber;
    settleBet(queryId, randomNumber);
  }

  // // Function that will be executed after callback by provable oracle.
  // function callbackFunction(uint256 randomNumber, bytes32 queryId) public {
  //   address payable player = address(uint160(historyBets[queryId].player));
  //   uint256 betAmount = historyBets[queryId].betAmount;
  //   uint256 guessNumber = historyBets[queryId].guessNumber;
  //   string memory result = "You lose";
  //   historyBets[queryId].randomNumber = randomNumber;
  //
  //   if(guessNumber == randomNumber){
  //     result = "You win";
  //     betAmount = betAmount * 2;
  //     player.transfer(betAmount);
  //   }
  //   emit betResult(queryId, result, betAmount);
  // }

  function getQueryIDs(address player) public view returns(bytes32[] memory) {
    return playersQueryIds[player];
  }

  function getBetInfo(bytes32 queryId) public view returns(address player,
    uint256 betAmount, uint256 guessNumber, uint256 randomNumber) {
    return (historyBets[queryId].player, historyBets[queryId].betAmount,
      historyBets[queryId].guessNumber, historyBets[queryId].randomNumber);
  }

  function getPlayer(uint256 index) public view returns(address){
    return players[index];
  }


  uint256 constant NUMBER_RANDOM_BYTES = 1;
  uint256 EXECUTION_DELAY = 0;
  uint256 CALLBACK_GAS_LIMIT = 200000;
  // bool boolCallbackFunction = false;
  uint256 public moduloRN = 2; // Modula for determining range of the random number
  bytes32 public lastQueryID;

  event logNewProvableQuery(string description);
  event generatedRandomNumber(uint256 randomNumber);

  // constructor() public{
  //   generateRandomNumber();
  // }

  // function callbackFunction(uint256 randomNumber, bytes32 queryId, string memory _result, bytes memory _proof) public {}

  function __callback(bytes32 queryId, string memory _result, bytes memory _proof) public {
    // require(msg.sender == provable_cbAddress());

    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % moduloRN;
    historyBets[queryId].randomNumber = randomNumber;
    emit generatedRandomNumber(randomNumber);

    // settleBet(queryId, randomNumber); //Uncomment for provable RN
  }

  function settleBet(bytes32 queryId, uint256 randomNumber) internal {
    address payable player = address(uint160(historyBets[queryId].player));
    uint256 betAmount = historyBets[queryId].betAmount;
    uint256 guessNumber = historyBets[queryId].guessNumber;
    string memory result = "You lose";

    if(guessNumber == randomNumber){
      result = "You win";
      betAmount = betAmount * 2;
      player.transfer(betAmount);
    }
    emit betResult(queryId, result, betAmount);
  }

  function generateRandomNumber() payable public returns(bytes32){
    bytes32 queryId = testRandomNumber();
    // bytes32 queryId = provable_newRandomDSQuery(EXECUTION_DELAY,NUMBER_RANDOM_BYTES,
    //   CALLBACK_GAS_LIMIT);
    emit logNewProvableQuery("Query for random number has been sent. Waiting for response.");
    lastQueryID = queryId;
    return queryId;
  }

  function testRandomNumber() public returns(bytes32){
    bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
    __callback(queryId, "1", bytes("test"));
    return queryId;
  }
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
