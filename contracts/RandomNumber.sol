// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ILottery {
  function updateDrawNumbers(uint _number) external;
}

contract RandomNumber is VRFConsumerBase, Ownable {

  bytes32 internal keyHash;
  uint256 internal fee;
  address lottery;

  /**
  * Constructor inherits VRFConsumerBase
  *
  * Network: Kovan
  * Chainlink VRF Coordinator address: 0xf490AC64087d59381faF8Bf49Da299C073aAC152
  * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
  * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
  */
  constructor(address _lottery) VRFConsumerBase(
    // 0xf490AC64087d59381faF8Bf49Da299C073aAC152, // Kovan VRF Coordinator
    0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // Rinkeby VRF Coordinator
    // 0xa36085F69e2889c224210F603D836748e7dC0088  // Kovan LINK Token
    0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // Rinkeby LINK Token
  ) public
  {
    // keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4; // Kovan keyHash
    keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; // Rinkeby keyHash
    fee = 0.1 * 10 ** 18; // 0.1 LINK
    lottery = _lottery;
  }

  function setLottery(address _lottery) external onlyOwner{
    lottery = _lottery;
  }

  /**
  * Requests randomness from a user-provided seed
  */
  function getRandomNumber(uint256 userProvidedSeed) external returns (bytes32 requestId) {
    require(msg.sender == lottery, "invalid-address");
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee, userProvidedSeed);
  }

  /**
  * Callback function used by VRF Coordinator
  */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    require(randomness > 0, "wrong-number");
    ILottery iLottery = ILottery(lottery);
    iLottery.updateDrawNumbers(randomness);
  }
}
