// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (
            ,
            int price ,
            ,
            ,

        ) = priceFeed.latestRoundData();
        // price = price of ETH in term of USD
        // added 10 decimal placs to make it 18 digit as our ETH vlue is 1**18 Wie and USD value of ETH is always 10 ** 8
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18;

        return ethAmountInUSD;
    }
}
