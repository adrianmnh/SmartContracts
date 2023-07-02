// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IERC20.sol";

/**
 *  Exercise: [1] Write a smart contract that implements the ERC-20 standard.
 *            [2] Create a file `src/test/Token.t.sol` and write test cases for your ERC-20 smart contract.
 *                Look at the test case for exercise-1 as reference.
 *                
**/

contract Token is IERC20 {
    
    string public _name;
    string public _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _availableSupply;
    address public _supplyAddress;
    mapping (address => uint256) private _balances ;
    mapping (address => mapping(address => uint256)) private _allowances;
    
    constructor() {
        _name = "MyToken";
        _symbol = "MTT";
        _decimals = 8;
        _totalSupply = 2_000_000_000_000;
        _availableSupply = _totalSupply;
        _supplyAddress = msg.sender;
        _balances[_supplyAddress] = _availableSupply;
    }

    function fund(address to, uint256 amount) external returns (bool){
        require(_totalSupply >= amount, "Not enough Token supply");
        _availableSupply -= amount;
        _balances[_supplyAddress] -= amount;
        
        assert(_balances[_supplyAddress] == _availableSupply);
        

        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function availableSupply() external view returns(uint256) {
        return _availableSupply;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool){
        // require(to != address(0), "Invalid recipient address");
        require(_balances[msg.sender] >= amount, "Insufficient funds");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool){
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        require(_allowances[from][to] >= amount, "Not enough allowance");
        require(_balances[from] >= amount, "Not enough balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][to] -= amount;
        emit Transfer(from, to, amount);       
        return true;
    }
}