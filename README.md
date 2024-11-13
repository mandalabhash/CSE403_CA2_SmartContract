CSE403- Blockchain | CA-2 | 14-11-2024
---

# Smart Contract Explanation: Escrow for Baiting

## Problem Statement

The task requires the development of a smart contract for a basic **escrow mechanism** where two parties deposit funds into the contract, and the winner takes the entire amount based on a predetermined condition. The contract also includes a mechanism for emergency halts to ensure secure handling of the funds in case of any unexpected issues.

## Solution

Let's make a scenario to implement the smart contract of a **escrow machanism**.

### Scenario

**Raman** and **Suman** have made a bait on a Cricket Match, where both parties deposit their funds into the contract. **Preeti**, their sister, acts as the **mediator** and the contract owner. The contract is designed with the following functionality:

1. **Deposits**: Both Raman and Suman place their bets.
2. **Outcome Declaration**: The winner (either Raman or Suman) receives the full deposited amount based on the event's result.
3. **Draw**: If the match results in a draw, both bettors get their funds back.
4. **Emergency Mechanism**: Preeti, as the contract owner, can activate an emergency mode to halt the contract's operations and refund the funds to both parties, ensuring safety in case of unforeseen events.

## Relevant Code Snippets

### 1. **Bet Placement**
Raman and Suman can place their respective bets using the following functions:

```solidity
function placeBetA() public payable {
    require(msg.sender == bettorA, "Only Bettor A can place this bet.");
    require(msg.value > 0, "Bet amount must be greater than 0.");
    require(betAmountA == 0, "Bet already placed by Bettor A.");

    betAmountA = msg.value;
    emit FundsDeposited(bettorA, msg.value);
}

function placeBetB() public payable {
    require(msg.sender == bettorB, "Only Bettor B can place this bet.");
    require(msg.value == betAmountA, "Bet amount must match Bettor A's amount.");
    require(betAmountB == 0, "Bet already placed by Bettor B.");

    betAmountB = msg.value;
    emit FundsDeposited(bettorB, msg.value);
}
```

- **`placeBetA()`**: Allows Raman (Bettor A) to place a bet by sending Ether.
- **`placeBetB()`**: Allows Suman (Bettor B) to place a bet too.

### 2. **Outcome Declaration**
Preeti (the owner) can declare the winner or draw using these functions:

```solidity
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
```

- **`declareWinner()`**: Preeti declares the winner (either Raman or Suman) and transfers the total bet amount to the winner.
- **`declareDraw()`**: If the event results in a draw, both bettors receive their funds back.

### 3. **Emergency Mode**
Preeti can activate or deactivate the emergency mode to halt the contract's functions:

```solidity
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
```

- **`activateEmergency()`**: Preeti can activate the emergency mode to halt the contract's operations, ensuring no further actions like declaring a winner or draw can occur.
- **`deactivateEmergency()`**: Once the emergency is resolved, Preeti can deactivate the emergency mode, resuming normal operations.
- **`emergencyRefund()`**: If the emergency mode is active, Preeti can refund the deposits to both Raman and Suman to ensure safety.

### Purpose of the Emergency Mechanism

1. **Activate Emergency**: If there is an issue (e.g., the event is canceled), Preeti can activate the emergency mode to stop all functions, ensuring that the funds are not used or transferred during the emergency.
2. **Refund Funds**: Once the emergency mode is activated, Preeti can use the `emergencyRefund()` function to refund the deposits to Raman and Suman, safeguarding their funds.
3. **Deactivate Emergency**: After the issue is resolved, Preeti can deactivate the emergency mode, allowing the contract to resume normal operations.

---

## Conclusion

This smart contract ensures that Raman and Suman's funds are securely handled through an **escrow mechanism**. The **emergency switch** guarantees that funds can be refunded safely in case of any unforeseen issues, making the contract more secure and reliable in real-world scenarios.

---

Let me know if you need further assistance or additional details for the MD file!
