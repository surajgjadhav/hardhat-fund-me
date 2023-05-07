// async function deployFunc(hre) {
//     hre.getNamedAccounts()
//     hre.deployments
//     console.log("Hi!")
// }
// module.exports.default = deployFunc

const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

// we are retrieving required propes from hre in function param itself using interpolation
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log, get } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeedAddress"]
    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        // if the contract doesn't exist we deploy a minimal version of it for our local testing
        const ethUsdAggregator = await get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress =
            networkConfig[chainId]["ethUsdPriceFeedAddress"]
    }

    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, // put pricefeed adress
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        //verify contract
        await verify(fundMe.address, args)
    }

    log("---------------------------------------")
}

module.exports.tags = ["all", "fundme"]
