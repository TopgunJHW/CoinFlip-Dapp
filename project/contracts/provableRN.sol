import "./provableAPI.sol";
pragma solidity 0.5.12;

contract provableRN is usingProvable{

  uint256 constant NUMBER_RANDOM_BYTES = 1;
  uint256 public latestNumber;
  bool internal boolCallbackFunction = false;

  event logNewProvableQuery(string description);
  event generatedRandomNumber(uint256 randomNumber);

  constructor() public{
    update();
  }

  function callbackFunction(uint256 randomNumber, bytes32 queryId, string memory _result, bytes memory _proof) public {}

  function __callback(bytes32 queryId, string memory _result, bytes memory _proof) public {
    require(msg.sender == provable_cbAddress());

    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 100;
    latestNumber = randomNumber;
    emit generatedRandomNumber(randomNumber);

    if(boolCallbackFunction){
      callbackFunction(randomNumber, queryId, _result, _proof);
    }
  }

  function update() payable public{
    uint256 EXECUTION_DELAY = 0;
    uint256 CALLBACK_GAS_LIMIT = 200000;
    bytes32 queryId = provable_newRandomDSQuery(EXECUTION_DELAY,NUMBER_RANDOM_BYTES,
      CALLBACK_GAS_LIMIT);
    emit logNewProvableQuery("Query for random number has been sent. Waiting for response.");
  }
}
