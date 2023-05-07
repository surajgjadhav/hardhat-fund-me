const { ethers, getNamedAccounts, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { assert } = require("chai")

// we only run staging tests, only if the network is not hardhat/local
developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundeMe Staging Test", async function () {
          let fundMe
          let deployer
          const sendValue = ethers.utils.parseEther("0.03")

          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })

          it("allow people to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              await fundMe.withdraw()
              const endingBalance = await fundMe.provider.getBalance()
              assert.equal(endingBalance.toString(), "0")
          })
      })
