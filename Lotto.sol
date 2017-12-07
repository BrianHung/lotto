pragma solidity ^0.4.15;

contract Lotto {

    uint public prizePool;
    uint public mininumVal;

    address public lottoOwner;

    bool public open;

    bytes32 winningNumber;

    event LottoOpen(bool val);

    modifier OwnerOnly() {
        require (msg.sender == lottoOwner);
        _;
    }

    modifier liveLotto() {
        require (open == true);
        _;
    }

    modifier deadLotto() {
        require (open == false);
        _;
    }

    mapping (bytes32 => Players) bets;
    mapping (address => uint) winning;

    struct Players {
        uint pool; address[] unique;
        mapping (address => uint) bet;
        mapping (address => bool) player;
    }

    function Lotto(uint _mininumVal) public {
        lottoOwner = msg.sender;
        mininumVal = _mininumVal;
    }

    function closeLotto() public liveLotto OwnerOnly {
        open = false;
    }

    function openLotto() public deadLotto OwnerOnly {
        open = true;
    }

    function play(bytes32 guess) public payable liveLotto returns (bool) {

        uint betAmount = msg.value;
        address player = msg.sender;

        if (betAmount >= mininumVal) {

            prizePool += betAmount;

            bets[guess].pool += betAmount;
            bets[guess].bet[player] += betAmount;

            if (bets[guess].player[player] == false) {
                bets[guess].unique.push(player);
            }

            return true;

        } else {
            winning[player] += betAmount;
            return false;
        }
    }

    function reveal(bytes32 guess) public deadLotto {
        uint guessPool = bets[guess].pool;
        for (uint i = 0; i < bets[guess].unique.length; i += 1) {
            address player = bets[guess].unique[i];
            winning[player]= bets[guess].bet[player] / guessPool * prizePool;
        }
        winningNumber = guess;
    }

    function withdraw() public {
        address player = msg.sender;
        if (winning[player] > 0) {
            player.transfer(winning[player]);
        }
    }
}
