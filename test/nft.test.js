const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("nft minting functionality", async () => {
  let nft;

  beforeEach(async () => {
    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy("fake contract address");
    await nft.deployed();
  });

  it("should be able to create nft token", async () => {
    // const token = await nft.createToken(
    //   "ipfs://QmchaogtRPLHSi64vZUj3pG99DDtXTLrgXvLKchZbTBxRn"
    // );
    // console.log(token);
  });
});
