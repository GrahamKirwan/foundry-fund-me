// SPDX-License-Identifier: MIT

// Deploy mocks when we are on a local anvil chain
// Keep track of contract address acorss different chains

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/Mockv3Aggregator.sol";

pragma solidity ^0.8.24;

contract HelperConfig is Script {

    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab the exisitng address from the live network
    
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public currentActiveNetwork;

    constructor() {
        if (block.chainid == 11155111) { // If the chain id is 11155111 then we are on sepolia and we want to cal lour sepholia config function
            currentActiveNetwork = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            currentActiveNetwork = getMainnetEthConfig();
        } else {
            currentActiveNetwork = getOrCreateAnvilEthConfig();
        }
    }


    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        
        if(currentActiveNetwork.priceFeed != address(0)) { // If there is already an anvil chain deployed then just use that and return out of function
            return currentActiveNetwork;
        }

        vm.startBroadcast(); // Run a mock deploy and deploy our mock price feed contract that will return an address which we can use similairy to the above
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 2000e8); 
        vm.stopBroadcast();
        
        NetworkConfig memory anvilConfig = NetworkConfig(address(mockV3Aggregator));
        return anvilConfig;
    }

}