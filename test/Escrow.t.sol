pragma solidity ^0.8.13;

import "src/Escrow.sol";
import "forge-std/Test.sol";

contract EscrowTest is Test{
    Token token;
    EscrowV2 escrow;
    address payable alice;
    address payable bob;

    function setUp() public {

        token = new Token();
        alice = payable(address(0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA));
        bob = payable(address(0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB));
        vm.deal(bob, 1.1 ether);
        
        token.fund(alice, 100_000);
        

        vm.prank(bob);
        escrow = new EscrowV2(alice, address(token), 10_000, 5);

        vm.prank(alice);
        token.approve(address(escrow), 10_000);
    }

    function test_setup() public view {
        assert(token.balanceOf(alice) == 100_000);
        assert(token.allowance(alice, address(escrow)) == 10_000);
    }

    function test_before_executeEscrow() public {
        assertTrue(token.balanceOf(alice) == 100_000);
        assertTrue(token.balanceOf(bob) == 0);
        assert(bob.balance == 1.1 ether);
        assert(alice.balance == 0 ether);
        assert(address(escrow).balance == 0 ether);      
    }

    function test_fund_escrow() public {
        vm.prank(bob);
        escrow.fundEscrow{value:1 ether}();
        assertTrue(address(escrow).balance == 1 ether);
        assertTrue(address(bob).balance == 0.1 ether);
    }
    
    function test_execute_escrow() public {
        test_fund_escrow();
        vm.prank(alice);
        escrow.executeEscrow();
    }

    function test_balances_after() public {
        test_execute_escrow();
        assertTrue(address(escrow).balance == 0 ether);
        assertTrue(address(alice).balance == 1 ether);
        assertTrue(address(bob).balance == 0.1 ether);
        assertTrue(token.balanceOf(alice) == 90_000);
        assertTrue(token.balanceOf(bob) == 10_000);
    }

    function test_execute_wrong_sender() public {
        vm.expectRevert();
        vm.prank(bob);
        escrow.executeEscrow();
    }

    function test_withdraw_wrong_sender() public {
        vm.expectRevert();
        vm.prank(alice);
        escrow.withdrawEther();
    }

    function test_withdraw_before_expiry() public {
        vm.prank(bob);
        escrow.fundEscrow{value:1 ether}();
        vm.expectRevert();
        vm.prank(bob);
        escrow.withdrawEther();
    }

    function test_withdraw_after_expiry() public {
        vm.startPrank(bob);
        escrow.fundEscrow{value:1 ether}();
        vm.warp(block.timestamp + 5 days);
        escrow.withdrawEther();
        assert(address(bob).balance == 1.1 ether );
        assert(address(alice).balance == 0 ether);
        assert(address(escrow).balance == 0 ether);      
    }

    function test_escrow_already_executed() public {
        test_execute_escrow();
        vm.expectRevert();
        vm.prank(alice);
        escrow.executeEscrow();
    }

    function test_escrow_already_withdrawn() public {
        vm.prank(bob);
        escrow.fundEscrow{value:1 ether}();
        vm.warp(block.timestamp + 5 days);
        vm.prank(bob);
        escrow.withdrawEther();
        vm.expectRevert();
        vm.prank(bob);
        escrow.withdrawEther();
    }
}