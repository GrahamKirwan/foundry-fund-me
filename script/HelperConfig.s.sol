// SPDX-License-Identifier: MIT

// Deploy mocks when we are on a local anvil chain
// Keep track of contract address acorss different chains

import {Script} from "../lib/forge-std/src/Script.sol";

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
            currentActiveNetwork = getAnvilEthConfig();
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

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
    }
}