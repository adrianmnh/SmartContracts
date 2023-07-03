pragma solidity ^0.8.13;

import "./Token.sol";

contract Escrow {

    address public bob;
    address public alice;
    Token public token;
    uint public tokenAmount;
    uint public etherAmount;
    uint public escrowDeadline;
    bool public escrowExecuted;
    bool public etherWithdrawn;

    constructor (uint _ether, address _alice, address _tokenAddress, uint _amount, uint _hours) payable {
        require(msg.value == 1 ether, "Escrow contract must be funded by initiating party(Bob)");
        bob = msg.sender;
        etherAmount = _ether;
        require(msg.value == etherAmount, "Bob must deposit ether");
        alice = _alice;
        token = Token(_tokenAddress);
        tokenAmount = _amount;
        escrowDeadline = block.timestamp + _hours * 1 hours;
        escrowExecuted = false;
        etherWithdrawn = false;
    }

    modifier aliceOnly() {
        require(msg.sender == alice, "Only Alice allowed to execute");
        _;
    }
    modifier bobOnly() {
        require(msg.sender == bob, "Only Bob can withdraw ether after expiry");
        _;
    }

    function executeEscrow() external aliceOnly payable {
        require(!escrowExecuted, "Escrow already executed");
        require(block.timestamp <= escrowDeadline, "Escrow has expired");
        require(token.approve(bob, tokenAmount), "Token approval failed" );

        require(token.transferFrom(msg.sender, bob, tokenAmount), "Unable to Transfer Balance");
        escrowExecuted = true;
        payable(alice).transfer(etherAmount);
    }

    function withdrawEther() external bobOnly payable {
        require(!etherWithdrawn, "Ether already withdrawn");
        require(!escrowExecuted, "Escrow was executed");
        require(block.timestamp > escrowDeadline, "Escrow still active");

        etherWithdrawn = true;

        payable(bob).transfer(etherAmount);
    }

    function passTime() external {
        escrowDeadline -= 3601;
    }
}