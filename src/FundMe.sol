// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24; 

// Import our PriceConverter library 
import {PriceConverter} from './PriceConverter.sol';
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {

    // Lets us use the functions in PriceConverter.sol on all uint256 types
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; 

    address[] public funders;
    mapping (address => uint256) public addressToAmountFunder;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable { 
        // ** If this require statement fails, nothing after this line of code will execute, and gas will be refunded for all computation after this line.
        // ** Also, if a state variable is changed in the line before this require statement and the require fails, the state variable chnage will be reset to original state
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunder[msg.sender] = addressToAmountFunder[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {

        // Reset the mapping amounts
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunder[funder] = 0;
        }

        // Rest the array
        funders = new address[](0);

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

    function getVersion() public view returns (uint256) { // This will only work if run on sepholia testnet since thats where this contract address exists
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
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

}
