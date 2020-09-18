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

  event RequestIsOption(
    bytes32 indexed requestId
  );

  event RequestOptionDesc(
    bytes32 indexed requestId
  );

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

  event FulfillIsOption(
    bytes32 indexed requestId,
    bool isOption
  );

  event FulfillOptionDesc(
    bytes32 indexed requestId,
    bytes32 optionDesc
  );

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
    bool isOption;
    bytes32 optionDesc;
  }

  struct Oracle{
    address oracleAddress;
    bytes32 bytes32JobId;
    bytes32 uint256JobId;
    bytes32 boolJobId;
    uint256 oraclePayment;
  }

  mapping(bytes32 => Game) public games;

  mapping(bytes32 => Oracle) public oracles;

  bytes32 public oracleName;
  bytes32 public game;

  constructor(string memory _oracleName, address _oracleAddress, string memory _bytes32JobId, string memory _uint256JobId, string memory _boolJobId, string memory _game) public {
    setPublicChainlinkToken();

    // Oracle
    oracleName = stringToBytes32(_oracleName);
    Oracle storage oracle = oracles[oracleName];
    oracle.oracleAddress = _oracleAddress;
    oracle.bytes32JobId = stringToBytes32(_bytes32JobId);
    oracle.uint256JobId = stringToBytes32(_uint256JobId);
    oracle.boolJobId = stringToBytes32(_boolJobId);
    oracle.oraclePayment = 0.1 * 10 ** 18; // 0.1 LINK

    // Game
    game = stringToBytes32(_game);
  }

  function requestAll(string calldata _apiKey, string calldata _game) public {
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
    requestIsOption(_apiKey, _game);
    requestOptionDesc(_apiKey, _game);
  }

  function requestName(string calldata _apiKey, string calldata _game) public {
    require(games[game].name == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].bytes32JobId, address(this), this.fulfillName.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "name");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestName(requestId);
  }

  function fulfillName(bytes32 _requestId, bytes32 _name) public recordChainlinkFulfillment(_requestId){
    emit FulfillName(_requestId, _name);
    games[game].name = _name;
  }

  function requestCountry(string calldata _apiKey, string calldata _game) public {
    require(games[game].country == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].bytes32JobId, address(this), this.fulfillCountry.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "country");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestCountry(requestId);
  }

  function fulfillCountry(bytes32 _requestId, bytes32 _country) public recordChainlinkFulfillment(_requestId){
    emit FulfillCountry(_requestId, _country);
    games[game].country = _country;
  }

  function requestState(string calldata _apiKey, string calldata _game) public {
    require(games[game].state == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].bytes32JobId, address(this), this.fulfillState.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "state");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestState(requestId);
  }

  function fulfillState(bytes32 _requestId, bytes32 _state) public recordChainlinkFulfillment(_requestId){
    emit FulfillState(_requestId, _state);
    games[game].state = _state;
  }

  function requestMainMin(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainMin == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillMainMin.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_min");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestMainMin(requestId);
  }

  function fulfillMainMin(bytes32 _requestId, uint256 _mainMin) public recordChainlinkFulfillment(_requestId){
    emit FulfillMainMin(_requestId, _mainMin);
    games[game].mainMin = _mainMin;
  }

  function requestMainMax(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainMax == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillMainMax.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_max");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestMainMax(requestId);
  }

  function fulfillMainMax(bytes32 _requestId, uint256 _mainMax) public recordChainlinkFulfillment(_requestId){
    emit FulfillMainMax(_requestId, _mainMax);
    games[game].mainMax = _mainMax;
  }

  function requestMainDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].mainDrawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillMainDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "main_drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestMainDrawn(requestId);
  }

  function fulfillMainDrawn(bytes32 _requestId, uint256 _mainDrawn) public recordChainlinkFulfillment(_requestId){
    emit FulfillMainDrawn(_requestId, _mainDrawn);
    games[game].mainDrawn = _mainDrawn;
  }

  function requestBonusMin(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusMin == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillBonusMin.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_min");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestBonusMin(requestId);
  }

  function fulfillBonusMin(bytes32 _requestId, uint256 _bonusMin) public recordChainlinkFulfillment(_requestId){
    emit FulfillBonusMin(_requestId, _bonusMin);
    games[game].bonusMin = _bonusMin;
  }

  function requestBonusMax(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusMax == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillBonusMax.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_max");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestBonusMax(requestId);
  }

  function fulfillBonusMax(bytes32 _requestId, uint256 _bonusMax) public recordChainlinkFulfillment(_requestId){
    emit FulfillBonusMax(_requestId, _bonusMax);
    games[game].bonusMax = _bonusMax;
  }

  function requestBonusDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].bonusDrawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillBonusDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "bonus_drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestBonusDrawn(requestId);
  }

  function fulfillBonusDrawn(bytes32 _requestId, uint256 _bonusDrawn) public recordChainlinkFulfillment(_requestId){
    emit FulfillBonusDrawn(_requestId, _bonusDrawn);
    games[game].bonusDrawn = _bonusDrawn;
  }

  function requestSameBalls(string calldata _apiKey, string calldata _game) public {
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].boolJobId, address(this), this.fulfillSameBalls.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "same_balls");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestSameBalls(requestId);
  }

  function fulfillSameBalls(bytes32 _requestId, bool _sameBalls) public recordChainlinkFulfillment(_requestId){
    emit FulfillSameBalls(_requestId, _sameBalls);
    games[game].sameBalls = _sameBalls;
  }

  function requestDigits(string calldata _apiKey, string calldata _game) public {
    require(games[game].digits == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillDigits.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "digits");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestDigits(requestId);
  }

  function fulfillDigits(bytes32 _requestId, uint256 _digits) public recordChainlinkFulfillment(_requestId){
    emit FulfillDigits(_requestId, _digits);
    games[game].digits = _digits;
  }

  function requestDrawn(string calldata _apiKey, string calldata _game) public {
    require(games[game].drawn == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].uint256JobId, address(this), this.fulfillDrawn.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "drawn");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestDrawn(requestId);
  }

  function fulfillDrawn(bytes32 _requestId, uint256 _drawn) public recordChainlinkFulfillment(_requestId){
    emit FulfillDrawn(_requestId, _drawn);
    games[game].drawn = _drawn;
  }

  function requestIsOption(string calldata _apiKey, string calldata _game) public {
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].boolJobId, address(this), this.fulfillIsOption.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "is_option");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestIsOption(requestId);
  }

  function fulfillIsOption(bytes32 _requestId, bool _isOption) public recordChainlinkFulfillment(_requestId){
    emit FulfillIsOption(_requestId, _isOption);
    games[game].isOption = _isOption;
  }

  function requestOptionDesc(string calldata _apiKey, string calldata _game) public {
    require(games[game].optionDesc == 0, "already-got-value" );
    Chainlink.Request memory req = buildChainlinkRequest(oracles[oracleName].bytes32JobId, address(this), this.fulfillOptionDesc.selector);
    req.add("get", string(abi.encodePacked("https://www.magayo.com/api/info.php", "?api_key=", _apiKey, "&game=", _game)));
    req.add("path", "option_desc");
    bytes32 requestId = sendChainlinkRequestTo(oracles[oracleName].oracleAddress, req, oracles[oracleName].oraclePayment);
    emit RequestOptionDesc(requestId);
  }

  function fulfillOptionDesc(bytes32 _requestId, bytes16 _optionDesc) public recordChainlinkFulfillment(_requestId){
    emit FulfillOptionDesc(_requestId, _optionDesc);
    games[game].optionDesc = _optionDesc;
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
  public
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

}
