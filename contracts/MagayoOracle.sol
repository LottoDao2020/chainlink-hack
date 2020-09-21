// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MagayoOracle is ChainlinkClient, Ownable {

  event RequestName(
    bytes32 indexed requestId
  );

  event RequestCountry(
    bytes32 indexed requestId
  );

  event RequestState(
    bytes32 indexed requestId
  );

  event RequestMainMin(
    bytes32 indexed requestId
  );

  event RequestMainMax(
    bytes32 indexed requestId
  );

  event RequestMainDrawn(
    bytes32 indexed requestId
  );

  event RequestBonusMin(
    bytes32 indexed requestId
  );

  event RequestBonusMax(
    bytes32 indexed requestId
  );

  event RequestBonusDrawn(
    bytes32 indexed requestId
  );

  event RequestSameBalls(
    bytes32 indexed requestId
  );

  event RequestDigits(
    bytes32 indexed requestId
  );

  event RequestDrawn(
    bytes32 indexed requestId
  );

  // event RequestIsOption(
  //   bytes32 indexed requestId
  // );

  // event RequestOptionDesc(
  //   bytes32 indexed requestId
  // );

  // event RequestNextDraw(
  //   bytes32 indexed requestId
  // );

  event FulfillName(
    bytes32 indexed requestId,
    bytes32 name
  );

  event FulfillCountry(
    bytes32 indexed requestId,
    bytes32 country
  );

  event FulfillState(
    bytes32 indexed requestId,
    bytes32 state
  );

  event FulfillMainMin(
    bytes32 indexed requestId,
    uint256 mainMin
  );

  event FulfillMainMax(
    bytes32 indexed requestId,
    uint256 mainMax
  );

  event FulfillMainDrawn(
    bytes32 indexed requestId,
    uint256 mainDrawn
  );

  event FulfillBonusMin(
    bytes32 indexed requestId,
    uint256 bonusMin
  );

  event FulfillBonusMax(
    bytes32 indexed requestId,
    uint256 bonusMax
  );

  event FulfillBonusDrawn(
    bytes32 indexed requestId,
    uint256 bonusDrawn
  );

  event FulfillSameBalls(
    bytes32 indexed requestId,
    bool sameBalls
  );

  event FulfillDigits(
    bytes32 indexed requestId,
    uint256 digits
  );

  event FulfillDrawn(
    bytes32 indexed requestId,
    uint256 drawn
  );

  // event FulfillIsOption(
  //   bytes32 indexed requestId,
  //   bool isOption
  // );

  // event FulfillOptionDesc(
  //   bytes32 indexed requestId,
  //   bytes32 optionDesc
  // );

  // event FulfillNextDraw(
  //   bytes32 indexed requestId,
  //   uint256 nextDraw
  // );

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
    uint256 duration;
    // bool isOption;
    // bytes32 optionDesc;
    // uint256 nextDraw;
  }

  // Oracle Info
  address oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
  bytes32 bytes32JobId = "50fc4215f89443d185b061e5d7af9490";
  bytes32 uint256JobId = "29fa9aa13bf1468788b7cc4a500a45b8";
  bytes32 boolJobId = "6d914edc36e14d6c880c9c55bda5bc04";
  uint256 oraclePayment = 0.1 * 10 ** 18; // 0.1 LINK;

  mapping(bytes32 => Game) public games;

  bytes32 public oracleName;
  bytes32 public game;

  constructor(string memory _game, uint256 _duration) public {
    setPublicChainlinkToken();

    // Game
    game = stringToBytes32(_game);
    // Should get from requestNextDraw but the conversion is difficult
    games[game].duration = _duration;
  }

  function requestAll(string calldata _apiKey, string calldata _game) external {
    requestName(_apiKey, _game);
    requestCountry(_apiKey, _game);
    requestState(_apiKey, _game);
    requestMainMin(_apiKey, _game);
    requestMainMax(_apiKey, _game);
    requestMainDrawn(_apiKey, _game);
    requestBonusMin(_apiKey, _game);
    requestBonusMax(_apiKey, _game);
    requestBonusDrawn(_apiKey, _game);
    requestSameBalls(_apiKey, _game);
    requestDigits(_apiKey, _game);
    // requestIsOption(_apiKey, _game);
    // requestOptionDesc(_apiKey, _game);
    // requestNextDraw(_apiKey, _game);
  }

  function requestName(string calldata _apiKey, string calldata _game) public {
    require(games[game].name == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(bytes32JobId, address(this), this.fulfillName.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "name");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestName(requestId);
  }

  function fulfillName(bytes32 _requestId, bytes32 _name) external recordChainlinkFulfillment(_requestId){
    emit FulfillName(_requestId, _name);
    games[game].name = _name;
  }

  function requestCountry(string calldata _apiKey, string calldata _game) public {
    require(games[game].country == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(bytes32JobId, address(this), this.fulfillCountry.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "country");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestCountry(requestId);
  }

  function fulfillCountry(bytes32 _requestId, bytes32 _country) external recordChainlinkFulfillment(_requestId){
    emit FulfillCountry(_requestId, _country);
    games[game].country = _country;
  }

  function requestState(string calldata _apiKey, string calldata _game) public {
    require(games[game].state == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(bytes32JobId, address(this), this.fulfillState.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "state");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestState(requestId);
  }

  function fulfillState(bytes32 _requestId, bytes32 _state) external recordChainlinkFulfillment(_requestId){
    emit FulfillState(_requestId, _state);
    games[game].state = _state;
  }

  function requestMainMin(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainMin == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillMainMin.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_min");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestMainMin(requestId);
  }

  function fulfillMainMin(bytes32 _requestId, uint256 _mainMin) external recordChainlinkFulfillment(_requestId){
    emit FulfillMainMin(_requestId, _mainMin);
    games[game].mainMin = _mainMin;
  }

  function requestMainMax(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainMax == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillMainMax.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_max");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestMainMax(requestId);
  }

  function fulfillMainMax(bytes32 _requestId, uint256 _mainMax) external recordChainlinkFulfillment(_requestId){
    emit FulfillMainMax(_requestId, _mainMax);
    games[game].mainMax = _mainMax;
  }

  function requestMainDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainDrawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillMainDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestMainDrawn(requestId);
  }

  function fulfillMainDrawn(bytes32 _requestId, uint256 _mainDrawn) external recordChainlinkFulfillment(_requestId){
    emit FulfillMainDrawn(_requestId, _mainDrawn);
    games[game].mainDrawn = _mainDrawn;
  }

  function requestBonusMin(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusMin == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillBonusMin.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_min");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestBonusMin(requestId);
  }

  function fulfillBonusMin(bytes32 _requestId, uint256 _bonusMin) external recordChainlinkFulfillment(_requestId){
    emit FulfillBonusMin(_requestId, _bonusMin);
    games[game].bonusMin = _bonusMin;
  }

  function requestBonusMax(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusMax == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillBonusMax.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_max");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestBonusMax(requestId);
  }

  function fulfillBonusMax(bytes32 _requestId, uint256 _bonusMax) external recordChainlinkFulfillment(_requestId){
    emit FulfillBonusMax(_requestId, _bonusMax);
    games[game].bonusMax = _bonusMax;
  }

  function requestBonusDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusDrawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillBonusDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestBonusDrawn(requestId);
  }

  function fulfillBonusDrawn(bytes32 _requestId, uint256 _bonusDrawn) external recordChainlinkFulfillment(_requestId){
    emit FulfillBonusDrawn(_requestId, _bonusDrawn);
    games[game].bonusDrawn = _bonusDrawn;
  }

  function requestSameBalls(string calldata _apiKey, string calldata _game) public {
    Chainlink.Request memory req = buildChainlinkRequest(boolJobId, address(this), this.fulfillSameBalls.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "same_balls");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestSameBalls(requestId);
  }

  function fulfillSameBalls(bytes32 _requestId, bool _sameBalls) external recordChainlinkFulfillment(_requestId){
    emit FulfillSameBalls(_requestId, _sameBalls);
    games[game].sameBalls = _sameBalls;
  }

  function requestDigits(string calldata _apiKey, string calldata _game) public {
    require(games[game].digits == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillDigits.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "digits");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestDigits(requestId);
  }

  function fulfillDigits(bytes32 _requestId, uint256 _digits) external recordChainlinkFulfillment(_requestId){
    emit FulfillDigits(_requestId, _digits);
    games[game].digits = _digits;
  }

  function requestDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].drawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(uint256JobId, address(this), this.fulfillDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
    emit RequestDrawn(requestId);
  }

  function fulfillDrawn(bytes32 _requestId, uint256 _drawn) external recordChainlinkFulfillment(_requestId){
    emit FulfillDrawn(_requestId, _drawn);
    games[game].drawn = _drawn;
  }

  // function requestIsOption(string calldata _apiKey, string calldata _game) public {
  //   Chainlink.Request memory req = buildChainlinkRequest(boolJobId, address(this), this.fulfillIsOption.selector);
  //   req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
  //   req.add("path", "is_option");
  //   bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
  //   emit RequestIsOption(requestId);
  // }

  // function fulfillIsOption(bytes32 _requestId, bool _isOption) external recordChainlinkFulfillment(_requestId){
  //   emit FulfillIsOption(_requestId, _isOption);
  //   games[game].isOption = _isOption;
  // }

  // function requestOptionDesc(string calldata _apiKey, string calldata _game) public {
  //   require(games[game].optionDesc == 0, "already-got-value" );
  //   Chainlink.Request memory req = buildChainlinkRequest(bytes32JobId, address(this), this.fulfillOptionDesc.selector);
  //   req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
  //   req.add("path", "option_desc");
  //   bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
  //   emit RequestOptionDesc(requestId);
  // }

  // function fulfillOptionDesc(bytes32 _requestId, bytes16 _optionDesc) external recordChainlinkFulfillment(_requestId){
  //   emit FulfillOptionDesc(_requestId, _optionDesc);
  //   games[game].optionDesc = _optionDesc;
  // }

  // function requestNextDraw(string calldata _apiKey, string calldata _game) public {
  //   require(games[game].nextDraw == 0, "already-got-value" );
  //   Chainlink.Request memory req = buildChainlinkRequest(bytes32JobId, address(this), this.fulfillNextDraw.selector);
  //   req.add("get", string(abi.encodePacked("https://www.magayo.com/api/next_draw.php", "?api_key=", _apiKey, "&game=", _game)));
  //   req.add("path", "next_draw");
  //   bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePayment);
  //   emit RequestNextDraw(requestId);
  // }

  // function fulfillNextDraw(bytes32 _requestId, bytes32 _nextDraw) external recordChainlinkFulfillment(_requestId){
  //   emit FulfillNextDraw(_requestId, _nextDraw);
  //   string memory nextDraw = bytes32ToString(_nextDraw);
  //   games[game].nextDraw = dt.toTimestamp(nextDraw[:3], nextDraw[5:6], nextDraw[9:9]);
  // }

  function withdrawLink() external onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
  external
  onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

  function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
    bytes32 _temp;
    uint count;
    for (uint256 i; i < 32; i++) {
      _temp = _bytes32[i];
      if( _temp != bytes32(0)) {
        count += 1;
      }
    }
    bytes memory bytesArray = new bytes(count);
    for (uint256 i; i < count; i++) {
      bytesArray[i] = (_bytes32[i]);
    }
    return (string(bytesArray));
  }

}
