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

    struct GameInfo {
        address payable escrow;
        address payable winner;
        mapping(address => uint) playerBalances;
        mapping(address => bool) players;
        string gameID;
        GameStatus status;
    }

    enum GameStatus { Created, InProgress, Completed }

    GameInfo[] public games;

    event BetPlaced(address player, uint amount);
    event WinnerDetermined(address winner);
    event GameAdded(address player, string gameID);

    constructor() public {
        owner = msg.sender;
    }

    function deposit(uint _gameId) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        require(_gameId < games.length, "Invalid game id");
        require(games[_gameId].status == GameStatus.InProgress, "Game is not in progress");
        playerBalances[msg.sender] += msg.value;
        players[msg.sender] = true;
        emit BetPlaced(msg.sender, msg.value);
    }

    function determineWinner(uint _gameId) public {
        require(_gameId < games.length, "Invalid game id");
        require(games[_gameId].status == GameStatus.InProgress, "Game is not in progress");
        require(players[msg.sender], "Player must have placed a bet");
        winner = msg.sender;
        games[_gameId].status = GameStatus.Completed;
        emit WinnerDetermined(winner);
    }

    function addGame(string memory _gameID) public {
        require(msg.sender == owner, "Only owner can add game");
        gameID[msg.sender] = _gameID;
        GameInfo memory newGame = GameInfo({
            escrow: address(this),
            winner: address(0),
            playerBalances: new mapping(address => uint)(),
            players: new mapping(address => bool)(),
            gameID: _gameID,
            status: GameStatus.Created
        });
        games.push(newGame);
        emit GameAdded(msg.sender, _gameID);
    }

    function startGame(uint _gameId) public {
        require(_gameId < games.length, "Invalid game id");
        require(games[_gameId].status == GameStatus.Created, "Game is already in progress or completed");
        games[_gameId].status = GameStatus.InProgress;
    }

   function payout(uint _gameId) public {
    require(_gameId < games.length, "Invalid game id");
    require(games[_gameId].status == GameStatus.Completed, "Game is not completed yet");
    require(games[_gameId].winner == msg.sender, "Only the winner can claim the prize");
    require(games[_gameId].players[msg.sender], "Winner must have placed a bet");
    games[_gameId].winner.transfer(games[_gameId].playerBalances[games[_gameId].winner]);
    delete games[_gameId].playerBalances[games[_gameId].winner];
    delete games[_gameId].players[games[_gameId].winner];
}

