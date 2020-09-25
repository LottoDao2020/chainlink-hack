// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IMagayoOracle {
  function game() external view returns (bytes32);

  function duration() external view returns (uint256);

  function games(bytes32 _game) external view returns (Game memory);

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
  function getRandomNumber(uint256 userProvidedSeed)
    external
    returns (bytes32 requestId);
}

interface IGovernance {
  function randomNumber() external view returns (address);

  function magayoOracle() external view returns (address);
}

contract Lottery is ChainlinkClient, Ownable {
  mapping(address => mapping(uint32 => uint64[][])) public entries;
  uint32 public drawNo;
  uint256 public prizePerEntry;
  uint256 public duration;
  uint256 public startTime;
  enum LOTTERY_STATE {CLOSED, OPEN, GETTING_RANDOMNUMBER}
  //  mapping (address => mapping(uint16 => Reward[])) results;

  mapping(address => mapping(uint32 => bool)) public claims;

  // Rinkeby
  uint256 public ORACLE_PAYMENT = 0.1 * 10**18;
  address CHAINLINK_ALARM_ORACLE = 0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e;
  bytes32 CHAINLINK_ALARM_JOB_ID = "4fff47c3982b4babba6a7dd694c9b204";
  IGovernance iGovernance;
  IMagayoOracle iMagayoOracle;
  IRandomNumber iRandomNumber;
  bytes32 game;
  uint256 mainDrawn;
  uint256 bonusDrawn;

  struct Draw {
    LOTTERY_STATE state;
    uint256 rewards;
    uint32[] numbers;
  }

  mapping(uint32 => Draw) public draws;

  event LogBuy(address currentUser, uint256 eValue, uint32[] numbers);
  event LogClaim(address currentUser, uint32 drawNo, uint256 reward);
  event LogNewLottery(uint32 drawNo, uint256 duration, uint256 startTime);

  constructor(uint256 _prizePerEntry, address _governance) public {
    setPublicChainlinkToken();
    prizePerEntry = _prizePerEntry;
    iGovernance = IGovernance(_governance);
    iMagayoOracle = IMagayoOracle(iGovernance.magayoOracle());
    iRandomNumber = IRandomNumber(iGovernance.randomNumber());
    game = iMagayoOracle.game();
    mainDrawn = iMagayoOracle.games(game).mainDrawn;
    bonusDrawn = iMagayoOracle.games(game).bonusDrawn;
    drawNo = 1;
  }

  function setPrice(uint256 _prizePerEntry) external onlyOwner {
    prizePerEntry = _prizePerEntry;
  }

  function setGovernance(address _governance) external onlyOwner {
    iGovernance = IGovernance(_governance);
  }

  function getEntries(uint32 _drawNo) external view returns(uint64[] memory numbers){
    // Due to nested array limitation we only return the last entry
    uint256 length = entries[msg.sender][_drawNo].length;
    numbers = entries[msg.sender][_drawNo][length - 1];
  }

  function getDrawState(uint32 _drawNo) external view returns(LOTTERY_STATE){
    return draws[_drawNo].state;
  }

  function getDrawRewards(uint32 _drawNo) external view returns(uint256){
    return draws[_drawNo].rewards;
  }

  function getDrawNumbers(uint32 _drawNo) external view returns(uint32[] memory){
    return draws[_drawNo].numbers;
  }

  function buy(uint32[] calldata numbers) external payable {
    require(msg.value >= prizePerEntry, "need-more-ether");
    require(draws[drawNo].state == LOTTERY_STATE.OPEN);
    entries[msg.sender][drawNo].push(numbers);
    emit LogBuy(msg.sender, msg.value, numbers);
  }

  function claim(uint32 _drawNo) external returns(uint256 amount) {
    require (draws[_drawNo].state == LOTTERY_STATE.CLOSED, "draw-is-not-closed");
    require (claims[msg.sender][drawNo] != true, "already-claimed");
    uint256[] memory results = getResults(_drawNo);
    require(results.length > 0, "no-win");
    for(uint32 i = 0; i < results.length; i++){
      amount += draws[_drawNo].rewards * results[i] / 100;
    }
    msg.sender.transfer(amount);
    claims[msg.sender][_drawNo] = true;
    emit LogClaim(msg.sender, _drawNo, amount);
  }

  function getResults(uint32 _drawNo) public view returns (uint256[] memory results){
    uint256 tickets = entries[msg.sender][_drawNo].length;
    for (uint32 i = 0; i < tickets; i++){
      uint32 mainWinning = 0;
      for (uint32 j = 0; j < mainDrawn; j++){
        for(uint32 k = 0; k < mainDrawn; k++){
          if(entries[msg.sender][_drawNo][i][j] == draws[_drawNo].numbers[k]){
            mainWinning++;
          }
        }
      }
      uint32 bonusWinning = 0;
      for (uint32 j = 0; j < bonusDrawn; j++){
        for(uint32 k = 0; k < bonusDrawn; k++){
          if(entries[msg.sender][_drawNo][i][j] == draws[_drawNo].numbers[k]){
            bonusWinning++;
          }
        }
      }
      uint32 prizeDistribution = calculatePrize(mainWinning, bonusWinning);
      if(prizeDistribution > 0){
        results[i] = prizeDistribution * draws[_drawNo].rewards / 100;
      }
    }
  }

  function calculatePrize(uint32 mainWinning, uint32 bonusWinning) internal view returns(uint32 prizeDistribution){
    if(mainWinning == 7){
      if(bonusWinning == 1){
        prizeDistribution = 35;
      }
      else{
        prizeDistribution = 2;
      }
    }
    if(mainWinning == 6){
      if(bonusWinning == 1){
        prizeDistribution = 1;
      }
      else{
        prizeDistribution = 2;
      }
    }
    if(mainWinning == 5){
      if(bonusWinning == 1){
        prizeDistribution = 2;
      }
      else{
        prizeDistribution = 7;
      }
    }
    if(mainWinning == 4 && bonusWinning == 1){
      prizeDistribution = 10;
    }
    if(mainWinning == 3 && bonusWinning == 1){
      prizeDistribution = 15;
    }
    if(mainWinning == 2 && bonusWinning == 1){
      prizeDistribution = 26;
    }
  }

  function startNewLottery(uint256 _duration) external onlyOwner {
    require(draws[drawNo].state == LOTTERY_STATE.CLOSED, "lottery-not-open");
    draws[drawNo].state = LOTTERY_STATE.OPEN;
    Chainlink.Request memory req = buildChainlinkRequest(
      CHAINLINK_ALARM_JOB_ID,
      address(this),
      this.fulfillAlarm.selector
    );
    // Using custom duration for easy testing
    // uint256 duration = iMagayoOracle.duration();
    duration = _duration;
    startTime = now;
    req.addUint("until", now + duration);
    sendChainlinkRequestTo(CHAINLINK_ALARM_ORACLE, req, ORACLE_PAYMENT);
    emit LogNewLottery(drawNo, duration, startTime);
  }

  function fulfillAlarm(bytes32 _requestId)
    external
    recordChainlinkFulfillment(_requestId)
  {
    require(draws[drawNo].state == LOTTERY_STATE.OPEN, "lottery-not-open");
    draws[drawNo].state = LOTTERY_STATE.GETTING_RANDOMNUMBER;
    iRandomNumber.getRandomNumber(
      now + block.number + drawNo + address(this).balance
    );
  }

  function updateDrawNumbers(uint256 _number) external {
    require(msg.sender == iGovernance.randomNumber(), "invalid-address");
    require(
      draws[drawNo].state == LOTTERY_STATE.GETTING_RANDOMNUMBER,
      "lottery-not-getting-random-number"
    );
    require(_number > 0, "wrong-number");
    draws[drawNo].state = LOTTERY_STATE.CLOSED;
    draws[drawNo].rewards = address(this).balance;
    for (uint32 i = 0; i < mainDrawn; i++) {
      draws[drawNo].numbers.push(uint32(_number % 100));
      _number = _number / 100;
    }
    for (uint32 i = 0; i < bonusDrawn; i++) {
      draws[drawNo].numbers.push(uint32(_number % 100));
      _number = _number / 100;
    }
    drawNo++;
  }
}
