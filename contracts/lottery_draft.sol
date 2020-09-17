pragma solidity ^0.6.0;

contract Lottery {
    mapping (address => mapping(uint16 => uint64 [][])) entries;
    uint32 draw_no;
    uint8 totalNum = 0;
    mapping (address => mapping(uint16 => mapping(uint64 => mapping(uint8 => bool)))) results;

	struct draw{
//	  enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER };
	  uint8 rewards;
	}

    mapping(uint8 => draw) draws;

    event LogBuy(address current_user, uint e_value, bytes entries);
    event LogClaim(address current_user, uint reward);

    function buy(bytes calldata _entries) external payable {
        uint8 prize_per_entry;
//    	require(msg.value >= entries * prize_per_entry, "needs more Ether");
	totalNum++;
    }

    function buy(uint64 []) external payable {
	totalNum++;
    }

    function validate(address _entries) private view returns(bool) {
        bool winning = false;
/*        for(uint i = 0; i < 10; i++) {
            if (entries[i] == _entry) {
                winning = true;
            }
        } */
        return winning;
    }
    
    function claim() private returns(address) {

      address payable winner;// = result_Chainlink_Oracle;    need to integrate with Chainlink Oracle

        winner.transfer(address(this).balance);
//        delete entries;
        totalNum = 0;
        return winner;
    }

    function claim(uint32 draw_no) external returns(uint8 amount) {
        uint8 amount = 0;
/*	if (results.includes(draw_no)) {

		amount = rewards_Chainlink_Oracle;	need to integrate with Chainlink Oracle

	} 
	else {
	amount = 0;
	}*/
        return amount;
    }

    function mockData (uint8 test1, uint8 test2) public{
//	    results[test1] = test1;
//	    draws[1] = test2;
    }

    function setOracle(address _oracle)  external{
/*        address onlyOwner;
    	oracle = _oracle; */
    }
    
}
