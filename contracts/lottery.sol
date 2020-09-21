pragma solidity ^0.6.12;

contract Lottery {
    mapping (address => mapping(uint32 => uint64 [][])) entries;
    uint32 drawNo;
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER }
	  LOTTERY_STATE lotteryState;
    uint8 prizePerEntry;
//    mapping (address => mapping(uint16 => Reward[])) results;
    mapping(address => mapping(uint32 => bool)) claims;

	struct draw{
	  LOTTERY_STATE state;
	  uint8 rewards;
	  uint32[] numbers;
	}

/*    interface IMagayoOracle{
        bytes32 public game;
        mapping(bytes32 => Game) public games;
        
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
        bytes32 nextDraw;
      }
    }

    IMagayoOracle iMagayoOracle = IMagayoOracle(address);
    bytes32 game = iMagayoOracle.game;
    uint256 mainDrawn = iMagayoOracle.games[game].mainDrawn;
    uint256 bonusDrawn = iMagayoOracle.games[game].bonusDrawn; */
bytes eee;
    mapping(uint32 => draw) draws;

    event LogBuy(address currentUser, uint eValue, bytes entries);
    event LogClaim(address currentUser, uint32 drawNo, uint reward); 

    function buy(uint64[] calldata numbers) external payable {
         eee="0x3333";
    	require(msg.value >= prizePerEntry, "need-more-Ether");
    	require(draws[drawNo].state == LOTTERY_STATE.OPEN);
    	entries[msg.sender][drawNo].push(numbers);
    	emit LogBuy(msg.sender, msg.value, eee);
    }

/*    function claim(uint32 drawNo) external returns(uint8 amount) {
        uint8 amount = 0;
        require (draws[drawNo].state != OPEN, "draw-still-open");
        require (results[msg.sender][drawNo].length > 0, "did-not-win");
        uint8 reward = results[msg.sender][drawNo][0].reward;
        bool claimed = results[msg.sender][drawNo][0].claimed;
        require (claimed == false, "already-claimed");
        amount = reward * draws[drawNo].rewards;
        msg.sender.transfer(address(this), amount);
        results[msg.sender][drawNo][0].claimed = true;
        emit LogClaim(currentUser, reward);
        return amount;
    }

    function getResults(uint32 _drawNo) view returns (uint32[] results){
        uint32 tickets = entries[msg.sender][_drawNo].length;
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
                if(entries[msg.sender][_drawNo][i][j] == draws[_drawNno].numbers[k]){
                  bonusWinning++;
              }
             }
            }
            uint32 prizeDistribution = calculatePrize(mainWinning, bonusWinning);
            if(prizeDistribution > 0){
              results.push( prizeDistribution * draws[_drawNo].rewards / 100);
            }
          }
    }
    
    function calculatePrize(uint32 mainWinning, uint32 bonusWinning) private view returns(uint32 prizeDistribution){
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
      if(mainWinning == 4 & bonusWinning == 1){
        prizeDistribution = 10;
      }
      if(mainWinning == 3 & bonusWinning == 1){
        prizeDistribution = 15;
      }
      if(mainWinning == 2 & bonusWinning == 1){
        prizeDistribution = 26;
      }
    }

    function mockData (uint8 test1, uint8 test2) public{
//	    results[test1] = test1;
//	    draws[1] = test2;
    }

    function setOracle(address _oracle)  external{
/*        address onlyOwner;
    	oracle = _oracle; */
//    }
    
}
