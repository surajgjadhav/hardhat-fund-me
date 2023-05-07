// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";

error FundMe__NotOwner();

/**
 * @title A contract for crowd funding
 * @author Suraj Jadhav
 * @notice Thsi contract is a sample funding contract
 * @dev This impliments price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State Variables!
    // use constant to the varibles which are not going to hange throghtout the code
    // this will help to minimize gas utilization
    uint256 constant MINIMUM_USD = 50 * 1e18; // 50 * 1 * 10 ** 18

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    // use immutable to the variable which is set only for one time but not at the time of declaration
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    // modifier
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        // converting above code into custom error code
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // _; is used to represent - execute remaining part of the function, when we call modifier for any function
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happpens if someone send ETH to this contract without calling the fund function
    // we have two function to track this condition
    // 1. receive()
    // 2. fallback()

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice this function funds this contract
     * @dev This impliments price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        ); 
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    /**
     * @notice this function withdraw money from accoun
     */
    function withdraw() public onlyOwner {
        console.log("Withdrawing amount..");
        // limiting withdraw to only owner of the contract
        // require(msg.sender == i_owner, "Sender is not owner!");

        // for loop
        // for(starting INdex, ending INdex, step amount)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex = funderIndex + 1
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset array
        s_funders = new address[](0);

        (bool callSuccess /*bytes memory dataReturned*/, ) = payable(msg.sender)
            .call{value: address(this).balance}("");
        require(callSuccess, "call Failed");
        console.log("Succesfully Withdrew money");
    }

    function cheaperWithdraw() public onlyOwner { 
        console.log("Withdrawing amount in chepaer amount of Gas..");
        // mapping are not in memory
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset array
        s_funders = new address[](0);

        (bool callSuccess /*bytes memory dataReturned*/, ) = payable(msg.sender)
            .call{value: address(this).balance}("");
        require(callSuccess, "call Failed");
        console.log("Succesfully Withdrew money with cheaper Gas");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddresToAmountFeed(address funder) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
