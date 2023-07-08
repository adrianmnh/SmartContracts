// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IERC20.sol";


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
        _name = "Dynamic Energy Fusion Token";
        _symbol = "DEFT";
        _decimals = 18;
        _totalSupply = 20_000_000_000 * 10**_decimals;
        _availableSupply = _totalSupply;
        _supplyAddress = msg.sender;
        _balances[_supplyAddress] = _availableSupply;
    }

    modifier ownerOnly () {
        require(msg.sender == _supplyAddress);
        _;
    }

    function fund(address to, uint256 amount) external returns (bool){
        require(msg.sender == _supplyAddress, "Only owner can fund");
        require(_totalSupply >= amount, "Not enough Token supply");
        require(msg.sender != to, "Not allowed");

        _availableSupply -= amount;

        _transfer(_supplyAddress, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Invalid recipient address");
        require(_balances[from] >= amount, "Not enough balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount); 

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
        _transfer(msg.sender, to, amount);
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
        if(msg.sender != from){
            require(_allowances[from][msg.sender] >= amount, "Not enough allowance");
            _allowances[from][msg.sender] -= amount;
        }
        _transfer(from, to, amount);     
        return true;
    }
}