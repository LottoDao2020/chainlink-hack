// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is Ownable {
  address public lottery;
  address public randomNumber;
  address public magayoOracle;

  constructor(address _magayoOracle) public {
    magayoOracle = _magayoOracle;
  }

  function setLottery(address _lottery) external onlyOwner {
    lottery = _lottery;
  }

  function setRandomNumber(address _randomNumber) external onlyOwner {
    randomNumber = _randomNumber;
  }

  function setMagayoOracle(address _magayoOracle) external onlyOwner {
    magayoOracle = _magayoOracle;
  }

}

