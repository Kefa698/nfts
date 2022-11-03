const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Nft Marketplace Unit Tests", function () {
          let nftMarketplace, nftMarketplaceContract, basicNft, basicNftContract
          const PRICE = ethers.utils.parseEther("0.1")
          const TOKEN_ID = 0

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              user = accounts[1]
              await deployments.fixture(["all"])
              nftMarketplaceContract = await ethers.getContract("Nft")
              nftMarketplace = await nftMarketplaceContract.connect(deployer)
              basicNftContract = await ethers.getContract("BasicNft")
              basicNft = await basicNftContract.connect(deployer)
              await basicNft.mintNft()
              await basicNft.approve(nftMarketplaceContract.address, TOKEN_ID)
          })
          describe("listitem", function () {
              it("emits an event after Listing", async function () {
                  expect(await nftMarketplace.listItem(basicNft.address, TOKEN_ID, PRICE)).to.emit(
                      "ItemListed"
                  )
              })
          })
      })
