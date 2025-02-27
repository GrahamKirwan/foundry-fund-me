// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe; 

    address USER = makeAddr("user"); // makeAddr is a foundry cheatcode that will create a fake user address that we can use in our test to simulate a user running a tx

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe(); // Updated from above line to be more modular - we will set up our fundMe contract based on our deploy script (which accepts chain pricefeed data address)
        fundMe = deployFundMe.run();
        vm.deal(USER, 10e18); // vm.deal is a foundry cheatcode to give our fake user ETH so they can make transactions
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view { // Test version depending on what chain we are testing on
        uint256 version;
        if (block.chainid == 11155111) {
            version = fundMe.getVersion(); 
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // This is esentially the opposite of 'assertEq' - the test will pass if the next line of code after this fails
        fundMe.fund(); // send 0 value - if transaction is empty this line will fail and the test will pass
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: 1e18}();
        assertEq(fundMe.getAddressToAmountFunded(USER), 1e18);
    }

    function testFundUpdatesFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: 1e18}();
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER); 
        fundMe.fund{value: 1e18}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public { 
        // Arrange
        vm.prank(USER); 
        fundMe.fund{value: 1e18}();

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (nb - gas functions are not neccessary here)
        uint256 gasStart = gasleft(); // gasleft() is a built in function to let us know the gas left that was sent with a transaction
        vm.txGasPrice(1000); // Foundry cheatcode to simulate gas usage when calling function
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }
}