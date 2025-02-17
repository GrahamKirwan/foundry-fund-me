// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe; 

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe(); // Updated from above line to be more modular - we will set up our fundMe contract based on our deploy script (which accepts chain pricefeed data address)
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.owner(), address(this));
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }
}