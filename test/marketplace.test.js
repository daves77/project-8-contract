const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("marketplace basic functionality", () => {
  let nft;
  let marketplace;

  beforeEach(async () => {
    const MarketPlace = await ethers.getContractFactory("MarketPlace");
    marketplace = await MarketPlace.deploy();
    await marketplace.deployed();

    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(marketplace.address);
    await nft.deployed();
  });

  it("can create nft token for listing", async () => {
    const x = await nft.createToken("https://mytokenlocation.com");
    console.log(x);
  });
});
