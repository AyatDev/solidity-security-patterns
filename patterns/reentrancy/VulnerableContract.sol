// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// VULNERABLE - Do not use in production
contract VulnerableWithdraw {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // BUG: state updated AFTER external call
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] = 0; // Too late!
    }
}

// FIXED - CEI Pattern
contract SecureWithdraw {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // FIXED: Checks-Effects-Interactions
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");
        balances[msg.sender] = 0; // State updated BEFORE external call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
