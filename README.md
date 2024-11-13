CSE403- Blockchain | CA-2 | 14-11-2024

# Smart Contract Explanation: Escrow Mechanism

## Problem Statement

The task requires the development of a smart contract for a basic **escrow mechanism** where two parties deposit funds into the contract, and the winner takes the entire amount based on a predetermined condition. The contract also includes a mechanism for emergency halts to ensure secure handling of the funds in case of any unexpected issues.

## Solution

Let's make a scenario to implement the smart contract of a **escrow machanism**.

### Scenario

- **Raman** and **Aman** place bets on a cricket match. They each deposit funds into the contract.
  - **If Raman’s team wins**, he takes the entire pooled funds.
  - **If Aman's team wins**, he takes the entire pooled funds.
  - **If the match results in a draw**, both Raman and Aman are refunded their respective amounts.
- **Preeti**, as the owner of the contract, acts as the mediator who:
  - Declares the winner of the bet and distributes the funds.
  - Declares a draw if the match is undecided, refunding both bettors.
  - Has an emergency switch to instantly refund both bettors in case of unforeseen issues.

---

## Key Components and Code Snippets

### 1. Contract Setup

The contract specifies the owner (Preeti), bettors (Raman and Aman), their respective bet amounts, and an emergency state variable.

```solidity
address public owner;
address public bettorA; // Represents Raman
address public bettorB; // Represents Aman
uint256 public betAmountA; // Raman's bet amount
uint256 public betAmountB; // Aman's bet amount
bool public isEmergency;
```

- **owner**: Address of Preeti, the contract mediator.
- **bettorA** and **bettorB**: Addresses of Raman and Aman, respectively.
- **betAmountA** and **betAmountB**: Track the funds deposited by each bettor.
- **isEmergency**: Boolean indicating if the contract is in an emergency state, disabling regular operations and triggering an automatic refund.

### 2. Placing Bets

Raman and Aman each place their bets by calling the respective functions `placeBetA()` and `placeBetB()`. Both functions are designed to accept any amount, allowing flexibility in bet sizes.

```solidity
function placeBetA() public payable { /*...*/ }
function placeBetB() public payable { /*...*/ }
```

- **Raman's Bet**: `placeBetA()` function allows Raman to place his bet by sending Ether.
- **Aman's Bet**: `placeBetB()` function allows Aman to place his bet by sending Ether.
- **Funds Deposited Event**: Emits an event whenever a bet is placed, recording the bettor’s address and the amount deposited.

### 3. Declaring the Winner

Once the match outcome is known, Preeti, as the owner, declares the winner using `declareWinner()`. The function transfers the entire pooled funds to the declared winner.

```solidity
function declareWinner(address winner) public onlyOwner {
    require(!isEmergency, "Cannot declare winner during emergency.");
    uint256 totalBetAmount = betAmountA + betAmountB;
    payable(winner).transfer(totalBetAmount);
}
```

- **Safety Check**: Ensures the contract is not in an emergency state before declaring a winner.
- **Winner Transfer**: All funds are transferred to the declared winner’s address, ending the contract’s obligation.

### 4. Declaring a Draw

If the match results in a draw, Preeti can use the `declareDraw()` function to refund both Raman and Aman. The function calls `refund()`, which handles the actual fund transfer back to each bettor.

```solidity
function declareDraw() public onlyOwner {
    require(!isEmergency, "Cannot declare draw during emergency.");
    refund();
}
```

- **Safety Check**: Verifies that the contract is not in an emergency state.
- **Refund Call**: Invokes the `refund()` function to return each bettor’s funds.

### 5. Emergency Switch and Automatic Refund

In case of an emergency, Preeti can trigger an emergency state with `triggerEmergency()`. This action automatically refunds both Raman and Aman, protecting their funds.

```solidity
function triggerEmergency() public onlyOwner {
    isEmergency = true;
    refund();
}
```

- **Emergency Activation**: Sets the contract into an emergency state.
- **Automatic Refund**: Calls `refund()` immediately, sending funds back to both Raman and Aman.

### 6. Refund Function

The `refund()` function returns each bettor’s funds. This function is used in both the `declareDraw()` and `triggerEmergency()` functions to handle refunds consistently.

```solidity
function refund() internal {
    if (betAmountA > 0) {
        payable(bettorA).transfer(betAmountA);
        betAmountA = 0;
    }
    if (betAmountB > 0) {
        payable(bettorB).transfer(betAmountB);
        betAmountB = 0;
    }
}
```

- **Funds Return**: Sends back the Ether deposited by each bettor.
- **State Reset**: Resets `betAmountA` and `betAmountB` to zero after the refund, ensuring the contract can be reused.

---

## Emergency Handling and Resumption

The emergency switch prioritizes the safety of Raman and Aman’s funds. When triggered, it immediately refunds both bettors, disabling other contract functionalities until the emergency state is manually cleared by the owner if a reactivation function is implemented.

---

## Security Considerations

- **Emergency Refunds**: Protects bettors' funds by automatically triggering refunds in emergencies.
- **Owner Control**: Only Preeti, the contract owner, can declare a winner, draw, or emergency.

---

This contract is a secure and fair betting mechanism, allowing for automatic refunds in emergencies, while Preeti acts as the responsible mediator for declaring match outcomes.
