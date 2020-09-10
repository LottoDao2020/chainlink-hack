pragma solidity ^0.4.21;

contract Lottery {
    mapping (address => mapping(uint8 => uint64 [][])) entries;
    uint8 totalnum = 0;
    uint nonce = 0;

    function buy() public payable {
        require(msg.value == 0.01 ether);
        require(participantsCount < 10);
        require(drawSituation(msg.sender) == false);
        results[totalnum] = msg.sender;
        totalnum++;
        if (totalnum == 10) {
            claim();
        }
    }

    function validate(address _entries) private view returns(bool) {
        bool winning = false;
        for(uint i = 0; i < 10; i++) {
            if (entries[i] == _entry) {
                winning = true;
            }
        }
        return winning;
    }
    
    function claim() private returns(address) {
        require(totalnum == 10);
        address winner = results[winnerNumber()];
        winner.transfer(address(this).balance);
        delete entries;
        totalnum = 0;
        return winner;
    }
    
    function winnerNumber() private returns(uint) {
        uint winner = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % 10;
        nonce++;
        return winner;
    }
}
