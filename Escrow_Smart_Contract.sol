// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract EscrowBaiting {
    address public owner;
    address public bettorA;
    address public bettorB;
    uint256 public betAmountA;
    uint256 public betAmountB;
    bool public isEmergency;

    event FundsDeposited(address indexed bettor, uint256 amount);
    event WinnerDeclared(address indexed winner, uint256 amount);
    event FundsRefunded(address indexed bettor, uint256 amount);
    event EmergencyActivated(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor(address _bettorA, address _bettorB) {
        owner = msg.sender;
        bettorA = _bettorA;
        bettorB = _bettorB;
    }

    function placeBetA() public payable {
        require(msg.sender == bettorA, "Only Bettor A can place this bet.");
        require(msg.value > 0, "Bet amount must be greater than 0.");
        require(betAmountA == 0, "Bet already placed by Bettor A.");

        betAmountA = msg.value;
        emit FundsDeposited(bettorA, msg.value);
    }

    function placeBetB() public payable {
        require(msg.sender == bettorB, "Only Bettor B can place this bet.");
        require(msg.value > 0, "Bet amount must be greater than 0.");
        require(betAmountB == 0, "Bet already placed by Bettor B.");

        betAmountB = msg.value;
        emit FundsDeposited(bettorB, msg.value);
    }

    function declareWinner(address winner) public onlyOwner {
        require(!isEmergency, "Cannot declare winner during emergency.");
        require(betAmountA > 0 && betAmountB > 0, "Both bets must be placed.");
        require(winner == bettorA || winner == bettorB, "Invalid winner address.");

        uint256 totalBetAmount = betAmountA + betAmountB;
        payable(winner).transfer(totalBetAmount);
        emit WinnerDeclared(winner, totalBetAmount);

        // Reset bets after funds are transferred
        betAmountA = 0;
        betAmountB = 0;
    }

    function declareDraw() public onlyOwner {
        require(!isEmergency, "Cannot declare draw during emergency.");
        require(betAmountA > 0 && betAmountB > 0, "Both bets must be placed.");

        // Call refund function to refund both bettors
        refund();
    }

    function triggerEmergency() public onlyOwner {
        require(!isEmergency, "Emergency already active.");
        
        isEmergency = true;
        emit EmergencyActivated(msg.sender);

        // Call refund function to refund both bettors automatically
        refund();
    }

    // Refund function to send back funds to both bettors
    function refund() internal {
        if (betAmountA > 0) {
            payable(bettorA).transfer(betAmountA);
            emit FundsRefunded(bettorA, betAmountA);
            betAmountA = 0;
        }
        
        if (betAmountB > 0) {
            payable(bettorB).transfer(betAmountB);
            emit FundsRefunded(bettorB, betAmountB);
            betAmountB = 0;
        }
    }
}
