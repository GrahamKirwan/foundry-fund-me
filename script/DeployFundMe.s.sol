// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// Since were running a script, always have to import this script file from forge
import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe){
        vm.startBroadcast(); // vm functions come from the forge foundry scripts cheatcodes, tells our code when to stat and end so we dont spend gas outside these functions
        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Create a new instance of FundMe with the pricefeed contract from the chain we want to run on
        vm.stopBroadcast();
        return fundMe;
    }
}