pragma solidity >=0.7.0 <0.9.0;


contract TicTacToe {

    address payable player1_;
    address payable player2_;
    address public lastPlayed_;
    address payable winner_;
    bool public gameOver_;
    uint256 public turnsTaken_;
    mapping(address => uint256) public bets_;

    address[9] private gameBoard_;

    /*
     * @notice Starts the game
     * @param _player1 Address of the first player
     * @param _player2 Address of the second player
    */
    
    function startGame(address _player1, address _player2) external {
        player1_ = payable(_player1);
        player2_ = payable(_player2);
    }
    
    /*
     * @notice Take your turn, selecting a board location
     * @param _boardLocation Location of the board to take
    */
    
    function takeTurn(uint256 _boardLocation) external {
        require(!gameOver_, "Game has ended.");
        require(msg.sender == player1_ || msg.sender == player2_, "Not a valid player.");
        require(gameBoard_[_boardLocation] == address(0x0), "Board location filled");
        require(msg.sender != lastPlayed_, "Not your turn.");
        
        gameBoard_[_boardLocation] = msg.sender;
        lastPlayed_ = msg.sender;
        turnsTaken_++;
        
        if (isWinner(msg.sender)) {
            winner_ = payable(msg.sender);
            gameOver_ = true;
            winner_.transfer(address(this).balance);
        } else if (turnsTaken_ == 9) {
            gameOver_ = true;
            player1_.transfer(bets_[player1_]);
            player2_.transfer(bets_[player2_]);
        }
    }

    /*
    * @notice Tells if the boardmove makes the player winner or not
    * @param player Address of the current player
    * @returns true/false based on the funcation execution
    */
    
    function isWinner(address player) private view returns(bool) {
        uint8[3][8] memory winningFilters = [
            [0,1,2],[3,4,5],[6,7,8],  // All combinations to check rows of the board
            [0,3,6],[1,4,7],[2,5,8],  // All combinations to check columns of the board
            [0,4,8],[6,4,2]           // All combinations to check the diagonals of the board
        ];
        
        for (uint8 i = 0; i < winningFilters.length; i++) {
            uint8[3] memory filter = winningFilters[i];
            if (
                gameBoard_[filter[0]]==player &&
                gameBoard_[filter[1]]==player &&
                gameBoard_[filter[2]]==player
            ) {
                return true;
            }
        }
        return false;
    }
    
    /*
     * @notice Places bet on the current game
    */

    function placeBet() external payable {
        require(msg.sender == player1_ || msg.sender == player2_, "Not a valid player.");
        bets_[msg.sender] = msg.value;
    }
    
    /*
     * @notice Returns the current board
     * @returns Array of addresses
    */
    function getBoard() external view returns(address[9] memory) {
        return gameBoard_;
    }
}