// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24; 

// Import our PriceConverter library 
import {PriceConverter} from './PriceConverter.sol';
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {

    // Lets us use the functions in PriceConverter.sol on all uint256 types
    using PriceConverter for uint256;


    address[] private s_funders;
    mapping (address => uint256) private s_addressToAmountFunder;


    uint256 public constant MINIMUM_USD = 5e18; 
    address public owner;
    AggregatorV3Interface private s_priceFeed;
 
    // Passing in a pricefeed makes our code more modular since we dont have to refactor for a new chain each time - we can specify the pricefeed address of the chain we are deploying on
    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable { 
        // ** If this require statement fails, nothing after this line of code will execute, and gas will be refunded for all computation after this line.
        // ** Also, if a state variable is changed in the line before this require statement and the require fails, the state variable chnage will be reset to original state
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunder[msg.sender] = s_addressToAmountFunder[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {

        // Reset the mapping amounts
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunder[funder] = 0;
        }

        // Rest the array
        s_funders = new address[](0);

        // Withdraw the funds - 3 ways to do this in solidity (transfer, send, call)
        
        // transfer (will return error if it fails, will auto revert if transaction fails) (msg.sender is of type address, so we need to typecast it to type payable address)
        // payable(msg.sender).transfer(address(this).balance);

        // send (will return bool, will only revert if we add the require check)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call (lower level, reccommended since its most gas effecient)
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256) { // Return the version of the chainlink price feed
        return s_priceFeed.version();
    }

    // Set up a modifier that only allows the contract owner to call certain functions
    modifier onlyOwner() {
        require (msg.sender == owner, "Must be owner to withdraw");
        _; // This means anything else in a function code will excecute at this point
    }

    // Route any transactions that send eth directly to the contract instead of calling the fund function to fund()
    receive() external payable {
        fund();
    }

    // Route any transactions that send eth directly to the contract instead of calling the fund function to fund()
    fallback() external payable {
        fund();
    }

    // View / Pure functions (Getters) - These are used so our storage variables can be set to priavte for gas effeciency and also makes our code much more readable

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunder[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

}
