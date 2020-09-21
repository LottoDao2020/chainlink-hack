pragma solidity ^0.6;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IMagayoOracle{
  function game() external returns(bytes32);
  function duration() external returns(uint);
  function games(bytes32 _game) external returns(Game memory);

  struct Game {
    bytes32 name;
    bytes32 country;
    bytes32 state;
    uint256 mainMin;
    uint256 mainMax;
    uint256 mainDrawn;
    uint256 bonusMin;
    uint256 bonusMax;
    uint256 bonusDrawn;
    bool sameBalls;
    uint256 digits;
    uint256 drawn;
  }
}

interface IRandomNumber {
  function getRandomNumber(uint256 userProvidedSeed) external returns (bytes32 requestId);
}

contract Lottery is ChainlinkClient, Ownable {
  mapping (address => mapping(uint32 => uint64 [][])) entries;
  uint32 public drawNo;
  uint8 public prizePerEntry;
  address magayoOracle;
  address randomNumber;
  enum LOTTERY_STATE { OPEN, CLOSED, GETTING_RANDOMNUMBER }
  //  mapping (address => mapping(uint16 => Reward[])) results;
  mapping(address => mapping(uint32 => bool)) claims;

  // Rinkeby
  uint256 public ORACLE_PAYMENT = 0.1 * 10 ** 18;
  address CHAINLINK_ALARM_ORACLE = 0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e;
  bytes32 CHAINLINK_ALARM_JOB_ID = "4fff47c3982b4babba6a7dd694c9b204";

  struct Draw{
    LOTTERY_STATE state;
    uint256 rewards;
    uint32[] numbers;
  }

  mapping(uint32 => Draw) draws;

  constructor(uint8 _prizePerEntry, address _magayoOracle, address _randomNumber) public {
    prizePerEntry = _prizePerEntry;
    magayoOracle = _magayoOracle;
    randomNumber = _randomNumber;
  }

  function setMagayoOracle(address _magayoOracle) external onlyOwner{
    magayoOracle = _magayoOracle;
  }

  function setPrice(uint8 _prizePerEntry) external onlyOwner{
    prizePerEntry = _prizePerEntry;
  }

  function setRandomNumber(address _randomNumber) external onlyOwner{
    randomNumber = _randomNumber;
  }

  IMagayoOracle iMagayoOracle = IMagayoOracle(magayoOracle);
  bytes32 game = iMagayoOracle.game();
  uint duration = iMagayoOracle.duration();
  uint256 mainDrawn = iMagayoOracle.games(game).mainDrawn;
  uint256 bonusDrawn = iMagayoOracle.games(game).bonusDrawn;

  event LogBuy(address currentUser, uint eValue, uint32[] numbers);
  event LogClaim(address currentUser, uint32 drawNo, uint reward);

  function buy(uint32[] calldata numbers) external payable {
    require(msg.value >= prizePerEntry, "need-more-Ether");
    require(draws[drawNo].state == LOTTERY_STATE.OPEN);
    entries[msg.sender][drawNo].push(numbers);
    emit LogBuy(msg.sender, msg.value, numbers);
  }

  // function claim(uint32 drawNo) external returns(uint8 amount) {
  //   uint8 amount = 0;
  //   require (draws[drawNo].state != OPEN, "draw-still-open");
  //   require (results[msg.sender][drawNo].length > 0, "did-not-win");
  //   uint8 reward = results[msg.sender][drawNo][0].reward;
  //   bool claimed = results[msg.sender][drawNo][0].claimed;
  //   require (claimed == false, "already-claimed");
  //   amount = reward * draws[drawNo].rewards;
  //   msg.sender.transfer(address(this), amount);
  //   results[msg.sender][drawNo][0].claimed = true;
  //   emit LogClaim(currentUser, reward);
  //   return amount;
  // }

  // function getResults(uint32 _drawNo) view returns (uint32[] results){
  //   uint32 tickets = entries[msg.sender][_drawNo].length;
  //   for (uint32 i = 0; i < tickets; i++){
  //     uint32 mainWinning = 0;
  //     for (uint32 j = 0; j < mainDrawn; j++){
  //       for(uint32 k = 0; k < mainDrawn; k++){
  //         if(entries[msg.sender][_drawNo][i][j] == draws[_drawNo].numbers[k]){
  //           mainWinning++;
  //         }
  //       }
  //     }
  //     uint32 bonusWinning = 0;
  //     for (uint32 j = 0; j < bonusDrawn; j++){
  //       for(uint32 k = 0; k < bonusDrawn; k++){
  //         if(entries[msg.sender][_drawNo][i][j] == draws[_drawNno].numbers[k]){
  //           bonusWinning++;
  //         }
  //       }
  //     }
  //     uint32 prizeDistribution = calculatePrize(mainWinning, bonusWinning);
  //     if(prizeDistribution > 0){
  //       results.push( prizeDistribution * draws[_drawNo].rewards / 100);
  //     }
  //   }
  // }

  // function calculatePrize(uint32 mainWinning, uint32 bonusWinning) private view returns(uint32 prizeDistribution){
  //   if(mainWinning == 7){
  //     if(bonusWinning == 1){
  //       prizeDistribution = 35;
  //     }
  //     else{
  //       prizeDistribution = 2;
  //     }
  //   }
  //   if(mainWinning == 6){
  //     if(bonusWinning == 1){
  //       prizeDistribution = 1;
  //     }
  //     else{
  //       prizeDistribution = 2;
  //     }
  //   }
  //   if(mainWinning == 5){
  //     if(bonusWinning == 1){
  //       prizeDistribution = 2;
  //     }
  //     else{
  //       prizeDistribution = 7;
  //     }
  //   }
  //   if(mainWinning == 4 & bonusWinning == 1){
  //     prizeDistribution = 10;
  //   }
  //   if(mainWinning == 3 & bonusWinning == 1){
  //     prizeDistribution = 15;
  //   }
  //   if(mainWinning == 2 & bonusWinning == 1){
  //     prizeDistribution = 26;
  //   }
  // }

  function startNewLottery() external onlyOwner{
    require(draws[drawNo].state == LOTTERY_STATE.OPEN, "lottery-not-open");
    Chainlink.Request memory req = buildChainlinkRequest(CHAINLINK_ALARM_JOB_ID, address(this), this.fulfillAlarm.selector);
    req.addUint("until", now + duration);
    sendChainlinkRequestTo(CHAINLINK_ALARM_ORACLE, req, ORACLE_PAYMENT);
  }

  function fulfillAlarm(bytes32 _requestId) external recordChainlinkFulfillment(_requestId) {
    require(draws[drawNo].state == LOTTERY_STATE.OPEN, "lottery-not-open");
    draws[drawNo].state = LOTTERY_STATE.GETTING_RANDOMNUMBER;
    IRandomNumber iRandomNumber = IRandomNumber(randomNumber);
    iRandomNumber.getRandomNumber(now + block.number + drawNo + address(this).balance);
  }

  function updateDrawNumbers(uint _number) external {
    require(msg.sender == randomNumber, "invalid-address");
    require(draws[drawNo].state == LOTTERY_STATE.GETTING_RANDOMNUMBER, "lottery-not-getting-random-number");
    require(_number > 0, "wrong-number");
    draws[drawNo].state = LOTTERY_STATE.CLOSED;
    draws[drawNo].rewards = address(this).balance;
    for(uint32 i = 0; i < mainDrawn; i++){
      draws[drawNo].numbers.push(uint32(_number % 100));
      _number = _number / 100;
    }
    for(uint32 i = 0; i < bonusDrawn; i++){
      draws[drawNo].numbers.push(uint32(_number % 100));
      _number = _number / 100;
    }
    drawNo ++;
  }
}
