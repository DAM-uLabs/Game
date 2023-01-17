pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol";

contract Game {
    address payable public owner;
    mapping(address => uint) public playerBalances;
    mapping(address => bool) public players;
    mapping(address => string) public gameID;
    address payable public winner;
    address payable public escrow;
    string public gameName;

    event BetPlaced(address player, uint amount);
    event WinnerDetermined(address winner);
    event GameAdded(address player, string gameID);

    constructor() public {
        owner = msg.sender;
        escrow = address(this);
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        playerBalances[msg.sender] += msg.value;
        players[msg.sender] = true;
        emit BetPlaced(msg.sender, msg.value);
    }

    function determineWinner() public {
        require(players[msg.sender], "Player must have placed a bet");
        winner = msg.sender;
        emit WinnerDetermined(winner);
    }

    function addGame(string memory _gameID) public {
        require(msg.sender == owner, "Only owner can add game");
        gameID[msg.sender] = _gameID;
        emit GameAdded(msg.sender, _gameID);
    }

    function payout() public {
        require(msg.sender == winner, "Only the winner can claim the prize");
        require(players[winner], "Winner must have placed a bet");
        winner.transfer(playerBalances[winner]);
        delete playerBalances[winner];
        delete players[winner];
    }
}
