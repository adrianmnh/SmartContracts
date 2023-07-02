pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token.sol";
import "ds-test/test.sol";

contract TokenTest is Test{

    Token MyToken;
    address deployer = address(0x0);
    address me = address(0x12011991);
    address friend = address(0x11021991);
    uint256 toFund = 999_999;
    address rando = address(0x1);

    function setUp() public {
        vm.prank(deployer);
        MyToken = new Token();
        MyToken.fund(friend, toFund);
        // MyToken.transferFrom(friend, me, 1_000_000);
        vm.prank(friend);
        MyToken.approve(me, 100_000);
        MyToken.transferFrom(friend, me, 100_000);

    }

    function test_fund(uint8 amount) public {
        MyToken.fund(rando, amount);
        bool balance = MyToken.balanceOf(rando) == amount; 
        assertTrue(balance);
    }

    function test_available_supply() public {
        bool supply = MyToken.availableSupply() == 2_000_000_000_000 - toFund;
        assertTrue(supply);
    }

    function test_address() public {
        bool initial_address = MyToken._supplyAddress() == deployer;
        assertTrue(initial_address);
    }

    function test_transfer() public {
        vm.prank(me);
        MyToken.approve(rando, 80);
        MyToken.transferFrom(me, rando, 80);
        assertTrue(MyToken.balanceOf(rando) == 80);
    }

}
