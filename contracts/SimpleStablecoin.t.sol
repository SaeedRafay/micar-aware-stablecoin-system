// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SimpleStablecoin} from "./SimpleStablecoin.sol";
import {Test} from "forge-std/src/Test.sol";

contract SimpleStablecoinTest is Test {
    SimpleStablecoin stable;
    address owner;
    address issuer;
    address user;

    function setUp() public {
        owner = address(this);
        issuer = address(0x1);
        user = address(0x2);
        stable = new SimpleStablecoin("EUR Stable POC", "EURp", issuer);
    }

    function test_InitialIssuerIsSet() public view {
        require(stable.issuer() == issuer, "Issuer should be set correctly");
    }

    function test_OwnerCanSetNewIssuer() public {
        address newIssuer = address(0x3);
        stable.setIssuer(newIssuer);
        require(stable.issuer() == newIssuer, "Issuer should be updated");
    }

    function test_IssuerCanRequestIssuance() public {
        vm.prank(issuer);
        vm.expectEmit(true, false, false, true);
        emit SimpleStablecoin.IssuanceRequested(user, 100 ether, "ref1");
        stable.requestIssuance(user, 100 ether, "ref1");
    }

    function test_OwnerCanMint() public {
        stable.mintFor(user, 100 ether);
        require(stable.balanceOf(user) == 100 ether, "User should have 100 tokens");
    }

    function test_UserCanRequestRedemption() public {
        stable.mintFor(user, 50 ether);
        
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit SimpleStablecoin.RedemptionRequested(user, 25 ether, "red1");
        stable.requestRedemption(25 ether, "red1");
    }

    function test_IssuerCanBurnAfterRedemption() public {
        stable.mintFor(user, 60 ether);
        
        vm.prank(issuer);
        stable.burnFromIssuer(user, 60 ether);
        
        require(stable.balanceOf(user) == 0, "User balance should be 0 after burn");
    }

    function test_PausePreventsMinting() public {
        stable.pause();
        
        vm.expectRevert();
        stable.mintFor(user, 1 ether);
    }

    function test_UnpauseAllowsMinting() public {
        stable.pause();
        stable.unpause();
        
        stable.mintFor(user, 1 ether);
        require(stable.balanceOf(user) == 1 ether, "Minting should work after unpause");
    }

    function testFuzz_MintAndBurn(uint128 amount) public {
        vm.assume(amount > 0);
        
        stable.mintFor(user, amount);
        require(stable.balanceOf(user) == amount, "Balance should match minted amount");
        
        vm.prank(issuer);
        stable.burnFromIssuer(user, amount);
        require(stable.balanceOf(user) == 0, "Balance should be 0 after burn");
    }

    function test_RevertWhenMintingToZeroAddress() public {
        vm.expectRevert();
        stable.mintFor(address(0), 1 ether);
    }

    function test_RevertWhenMintingZeroAmount() public {
        vm.expectRevert();
        stable.mintFor(user, 0);
    }

    function test_RevertWhenNonOwnerPauses() public {
        vm.prank(user);
        vm.expectRevert();
        stable.pause();
    }

    function test_RevertWhenSettingIssuerToZeroAddress() public {
        vm.expectRevert();
        stable.setIssuer(address(0));
    }
}
