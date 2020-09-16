pragma solidity ^0.6.0;

contract Lottery {
    mapping (address => mapping(uint16 => uint64 [][])) entries;
    uint32 draw_no;
    uint8 totalnum = 0;

	Struct draw{
	  enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER };
	  uint8 rewards;
	}

    mapping(uint8 => draw) draws;

    event LogBuy(address current_user, uint msg.value, bytes entries);
    event LogClaim(address current_user, uint reward);

    function buy(bytes calldata _entries) public external payable {
        uint8 prize_per_entry;
	require(msg.value >= entries * prize_per_entry, "needs more Ether");
        results[totalnum] = msg.sender;
	totalnum++;
    }

    function validate(address _entries) private view returns(bool) {
	mapping (address => mapping(uint16 => mapping(uint64 => mapping(uint8 => bool)))) results;
        bool winning = false;
        for(uint i = 0; i < 10; i++) {
            if (entries[i] == _entry) {
                winning = true;
            }
        }
        return winning;
    }
    
    function claim() private returns(address) {
	mapping (address => mapping(uint16 => mapping(uint64 => mapping(uint8 => bool)))) results;

//        address winner = result_Chainlink_Oracle;    need to integrate with Chainlink Oracle

        winner.transfer(address(this).balance);
        delete entries;
        totalnum = 0;
        return winner;
    }

    function claim(uint32 draw_no) public external returns(uint8 amount) {
	if (results.includes(draw_no)) {

//		amount = rewards_Chainlink_Oracle;	need to integrate with Chainlink Oracle

	}
	else {
	amount = 0;
	}
        return amount;
    }

    function mockData (uint8 test1, uint8 test2) external public{
	  results[test1] = test1;
	  draws[1] = test2;
    }

    function setOracle(address _oracle) onlyOwner public external{
    	oracle = _oracle
    }
    
}
