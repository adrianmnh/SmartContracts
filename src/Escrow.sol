// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Token.sol";

contract EscrowV2 {

    address payable public deployer;
    address payable public beneficiary;
    Token public token;
    uint public tokenAmount;
    uint public etherAmount;
    uint public escrowDeadline;
    bool public escrowExecuted;
    bool public etherWithdrawn;
    bool public escrowFunded;

    constructor (address payable _beneficiary, address _tokenAddress, uint _amount, uint _hours) {
        require(_tokenAddress != address(0), "Token address cannot be 0");
        require(_beneficiary != address(0), "beneficiary address cannot be 0");
        require(_hours > 0, "Hours must be greater than 0");
        require(_amount > 0, "Amount must be greater than 0");
        deployer = payable(msg.sender);
        beneficiary = _beneficiary;
        token = Token(_tokenAddress);
        tokenAmount = _amount;
        escrowDeadline = block.timestamp + _hours * 1 hours;
    }

    function fundEscrow() external deployerOnly payable {
        require(!escrowFunded, "Escrow already funded");
        require(block.timestamp <= escrowDeadline, "Escrow has expired");
        require(msg.value >= 1 gwei, "Ether amount must be at least 1 gwei");
        etherAmount = msg.value;
        escrowFunded = true;
    }

    modifier beneficiaryOnly() {
        require(msg.sender == beneficiary, "Only beneficiary allowed to execute");
        _;
    }
    modifier deployerOnly() {
        require(msg.sender == deployer, "Only deployer can withdraw ether after expiry");
        _;
    }
    modifier escrowFundedOnly() {
        require(escrowFunded, "Escrow not funded");
        _;
    }

    function executeEscrow() external beneficiaryOnly escrowFundedOnly {
        require(!escrowExecuted, "Escrow already executed");
        require(block.timestamp <= escrowDeadline, "Escrow has expired");
        require(token.allowance(beneficiary, address(this)) >= tokenAmount, "Not enough allowance to EscrowV2 contract");
        token.transferFrom(beneficiary, deployer, tokenAmount);
        payable(beneficiary).transfer(etherAmount);
        escrowExecuted = true;
    }

    function withdrawEther() external deployerOnly escrowFundedOnly {
        require(!etherWithdrawn, "Ether already withdrawn");
        require(!escrowExecuted, "Escrow was executed");
        require(block.timestamp > escrowDeadline, "Escrow still active");
        payable(deployer).transfer(etherAmount);
        etherWithdrawn = true;
    }
}