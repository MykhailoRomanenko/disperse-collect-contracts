// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DisperseCollect} from "../src/DisperseCollect.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DisperseCollectTest is Test {
    uint256 constant INITIAL_BALANCE = 10;
    uint256 constant NUM_ADDRESSES = 3;

    DisperseCollect public dc;
    ERC20Mock public token;
    address public owner;
    address payable[] public addresses;

    function setUp() public {
        owner = vm.addr(1);
        vm.deal(owner, INITIAL_BALANCE);

        dc = new DisperseCollect(owner);
        token = new ERC20Mock();
        token.mint(owner, INITIAL_BALANCE);

        addresses = new address payable[](NUM_ADDRESSES);
        for (uint256 i = 0; i < NUM_ADDRESSES; ++i) {
            addresses[i] = payable(vm.addr(i + 2));
            token.mint(addresses[i], INITIAL_BALANCE);
            vm.prank(addresses[i]);
            token.approve(address(dc), INITIAL_BALANCE);
        }

        vm.startPrank(owner);
        token.approve(address(dc), INITIAL_BALANCE);
    }

    function testShouldDisperseEthIfBalanceOk() public {
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 4;
        amounts[1] = 6;

        address[] memory recipients = getAddresses(2);

        dc.disperseEth{value: INITIAL_BALANCE}(recipients, amounts);

        for (uint256 i = 0; i < recipients.length; ++i) {
            assertEq(recipients[i].balance, amounts[i]);
        }
    }

    function testShouldDisperseEthPanicIfArgLenMismatch() public {
        uint256[] memory amounts = new uint256[](1);

        address[] memory recipients = getAddresses(2);

        vm.expectRevert();
        dc.disperseEth{value: INITIAL_BALANCE}(recipients, amounts);
    }

    function testShouldDisperseEthPanicIfBalanceInsufficient() public {
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = INITIAL_BALANCE + 1;
        amounts[1] = 6;

        address[] memory recipients = getAddresses(2);

        vm.expectRevert();
        dc.disperseEth{value: INITIAL_BALANCE}(recipients, amounts);
    }

    function testShouldDisperseERC20IfBalanceOk() public {
        uint256 recipientsLen = 2;
        uint256[] memory amounts = new uint256[](recipientsLen);
        amounts[0] = 4;
        amounts[1] = 6;

        uint256 totalSpent;
        for (uint256 i = 0; i < amounts.length; ++i) {
            totalSpent += amounts[i];
        }

        address[] memory recipients = getAddresses(recipientsLen);

        dc.disperseERC20(owner, address(token), recipients, amounts);

        for (uint256 i = 0; i < recipientsLen; ++i) {
            assertEq(token.balanceOf(recipients[i]), amounts[i] + INITIAL_BALANCE);
        }
        assertEq(token.balanceOf(owner), INITIAL_BALANCE - totalSpent);
    }

    function testShouldDisperseERC20PanicIfArgLenMismatch() public {
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 40;

        address[] memory recipients = getAddresses(1);

        vm.expectRevert();
        dc.disperseERC20(owner, address(token), recipients, amounts);
    }

    function testShouldDisperseERC20PanicIfBalanceInsufficient() public {
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = INITIAL_BALANCE + 1; // More than the owner's balance

        address[] memory recipients = new address[](1);

        token.approve(address(dc), 100);

        vm.expectRevert();
        dc.disperseERC20(owner, address(token), recipients, amounts);
    }

    function testShouldCollectERC20IfBalanceOk() public {
        uint256 sendersLen = 2;

        uint256[] memory amounts = new uint256[](sendersLen);
        amounts[0] = 10;
        amounts[1] = 10;

        uint256 totalSpent;
        for (uint256 i = 0; i < amounts.length; ++i) {
            totalSpent += amounts[i];
        }

        address[] memory senders = getAddresses(sendersLen);

        dc.collectERC20(address(token), owner, senders, amounts);

        assertEq(token.balanceOf(owner), INITIAL_BALANCE + totalSpent);
    }

    function testShouldCollectERC20PanicIfArgLenMismatch() public {
        uint256[] memory amounts = new uint256[](2);
        address[] memory senders = getAddresses(1);

        vm.expectRevert();
        dc.collectERC20(address(token), owner, senders, amounts);
    }

    function testShouldCollectERC20PanicIfBalanceInsufficient() public {
        uint256 sendersLen = 2;

        uint256[] memory amounts = new uint256[](sendersLen);
        amounts[0] = 100;
        amounts[1] = 100;

        address[] memory senders = getAddresses(sendersLen);

        vm.expectRevert();
        dc.collectERC20(address(token), owner, senders, amounts);
    }

    function getAddresses(uint256 count) internal view returns (address[] memory) {
        require(count < addresses.length);
        address[] memory slice = new address[](count);
        for (uint256 i = 0; i < count; ++i) {
            slice[i] = addresses[i];
        }
        return slice;
    }
}
