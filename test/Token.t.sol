pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "ds-test/test.sol";
import "src/Token.sol";

contract TokenTest is Test{

    Token MyToken;
    address deployer = address(0x99999999999999999999999999999);
    address me = address(0xAD51A);
    address friend = address(0x7AB1A);
    uint256 toFund = 999_999;
    address rando = address(0x123);

    function setUp() public {
        vm.prank(deployer);
        MyToken = new Token();
        vm.prank(deployer);
        MyToken.fund(friend, toFund);
        // MyToken.transferFrom(friend, me, 1_000_000);
        vm.prank(friend);
        MyToken.approve(address(this), 100_000);
        MyToken.transferFrom(friend, me, 100_000);

    }

    function test_fund_not_owner(uint8 amount) public {
        vm.expectRevert();
        MyToken.fund(rando, amount);
        // bool balance = MyToken.balanceOf(rando) == amount; 
        // assertTrue(balance);
    }

    function test_fund_owner(uint8 amount) public {
        vm.prank(deployer);
        MyToken.fund(rando, amount);
        bool balance = MyToken.balanceOf(rando) == amount; 
        assertTrue(balance);
    }

    function test_available_supply() public {
        bool supply = MyToken.availableSupply() == MyToken.totalSupply() - toFund;
        assertTrue(supply);
    }

    function test_address() public {
        bool initial_address = MyToken._supplyAddress() == deployer;
        assertTrue(initial_address);
    }

    function test_transfer() public {
        vm.prank(me);
        MyToken.approve(address(this), 80);
        MyToken.transferFrom(me, rando, 80);
        assertTrue(MyToken.balanceOf(rando) == 80);
    }

}
