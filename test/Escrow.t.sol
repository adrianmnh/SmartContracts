pragma solidity ^0.8.13;

import "src/Escrow.sol";
import "forge-std/Test.sol";

contract EscrowTest is Test{
    Token token;
    Escrow escrow;
    address alice;
    address payable bob;

    function setUp() public {

        token = new Token();
        alice = address(0x11021991);
        bob = payable(address(0x12011991));
        bob.transfer(1_000_000_999 gwei);

        token.fund(alice, 199);

        vm.prank(alice);
        token.approve(bob, 10);
        assert(token.allowance(alice, bob) == 10);

        vm.prank(bob);
        escrow = new Escrow{value:1 ether}(1 ether, alice, address(token), 10, 1);

    }

    function test_setup() public view {
        assert(token.balanceOf(alice) == 199);
    }

    function test_initial_ether() public view {

        assert(address(bob).balance == 999 gwei);
        assert(address(alice).balance == 0 ether);
        assert(address(escrow).balance == 1 ether);      

    }
    
    function test_balances_after() public {

        vm.prank(alice);
	    escrow.executeEscrow();
        assert(address(alice).balance == 1 ether);
        assert(address(escrow).balance == 0 ether);
    }

    function test_execute_wrong_sender() public {
        vm.prank(bob);
        escrow.executeEscrow();
    }

    function test_withdraw_wrong_sender() public {
        vm.prank(alice);
        escrow.withdrawEther();
    }

    function test_withdraw_before_expiry() public {
        vm.prank(bob);
        escrow.withdrawEther();
    }

    function test_withdraw_after_expiry() public {
        escrow.passTime();
        vm.prank(bob);
        escrow.withdrawEther();
        assert(address(bob).balance == 1_000_000_999 gwei);
        assert(address(alice).balance == 0 ether);
        assert(address(escrow).balance == 0 ether);      
    }

    function test_escrow_already_executed() public {
        vm.startPrank(alice);
        escrow.executeEscrow();
        escrow.executeEscrow();
        vm.stopPrank();
    }

    function test_escrow_already_withdrawn() public {
        escrow.passTime();
        vm.startPrank(bob);
        escrow.withdrawEther();
        escrow.withdrawEther();
        vm.stopPrank();
    }
}