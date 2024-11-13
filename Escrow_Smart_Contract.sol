// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract CricketMatchBet {
    address public owner;
    address public bettorA; // Raman
    address public bettorB; // Suman
    uint256 public betAmountA;
    uint256 public betAmountB;
    bool public isEmergency;

    event FundsDeposited(address indexed bettor, uint256 amount);
    event WinnerDeclared(address indexed winner, uint256 totalAmount);
    event FundsRefunded(address indexed bettor, uint256 amount);
    event EmergencyActivated(address indexed activatedBy);
    event EmergencyDeactivated(address indexed deactivatedBy);

    constructor(address _bettorA, address _bettorB) {
        owner = msg.sender; // Preeti, the contract owner and mediator
        bettorA = _bettorA;
        bettorB = _bettorB;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyInEmergency() {
        require(isEmergency, "Not in emergency mode.");
        _;
    }

    function placeBetA() public payable {
        require(msg.sender == bettorA, "Only Bettor A can place this bet.");
        require(msg.value > 0, "Bet amount must be greater than 0.");

        betAmountA = msg.value;
        emit FundsDeposited(bettorA, msg.value);
    }

    function placeBetB() public payable {
        require(msg.sender == bettorB, "Only Bettor B can place this bet.");
        require(msg.value == betAmountA, "Bet amount must match Bettor A's amount.");

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

        // Refund both bettors
        payable(bettorA).transfer(betAmountA);
        payable(bettorB).transfer(betAmountB);
        emit FundsRefunded(bettorA, betAmountA);
        emit FundsRefunded(bettorB, betAmountB);

        // Reset bets after refunds
        betAmountA = 0;
        betAmountB = 0;
    }

    function activateEmergency() public onlyOwner {
        isEmergency = true;
        emit EmergencyActivated(msg.sender);
    }

    function deactivateEmergency() public onlyOwner onlyInEmergency {
        isEmergency = false;
        emit EmergencyDeactivated(msg.sender);
    }

    function emergencyRefund() public onlyOwner onlyInEmergency {
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
