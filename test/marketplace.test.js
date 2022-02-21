const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("marketplace basic functionality", () => {
  let nft;
  let marketplace;
  let nftContractAddress;
  let user1;
  let user2;

  beforeEach(async () => {
    const MarketPlace = await ethers.getContractFactory("MarketPlace");
    marketplace = await MarketPlace.deploy();
    await marketplace.deployed();

    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(marketplace.address);
    await nft.deployed();

    nftContractAddress = nft.address;

    console.log("NFT Contract Address:", nft.address);
    console.log("Marketplace Address:", marketplace.address);

    const users = await ethers.getSigners();
    user1 = users[0];
    user2 = users[1];
  });

  it("nft contract should have the marketplace contract address", async () => {
    expect(await nft.marketplaceAddress()).to.equal(marketplace.address);
  });

  it("can create nft token for listing and retrieve tokenURI", async () => {
    const [user] = await ethers.getSigners();
    console.log(
      "user 1 address:",
      await user.getAddress(),
      await user.getBalance()
    );
    expect(
      await nft.createToken("https://mytokenlocation.com", {
        from: await user.getAddress(),
      })
    )
      .to.emit(nft, "TokenCreated")
      .withArgs(1);

    expect(await nft.tokeenURI(1).to.equal("https://mytokenlocation.com"));

    console.log(await nft.tokenURI(1));
  });

  it("can list the item onto the marketplace", async () => {
    console.log("new nft address:", nft.address);
    const userAddress = await user1.getAddress();
    const listingPrice = await marketplace.listingPrice();
    const sellingPrice = ethers.utils.parseUnits("3.4", "ether");

    await nft.createToken("https://mytokenlocation.com", {
      from: userAddress,
    });

    expect(
      await marketplace.createMarketItem(nft.address, 1, sellingPrice, {
        value: listingPrice,
        from: userAddress,
      })
    )
      .to.emit(marketplace, "MarketItemCreated")
      .withArgs(
        1,
        1,
        sellingPrice,
        nftContractAddress,
        userAddress,
        ethers.constants.AddressZero,
        false
      );
    const items = await marketplace.getAllMarketItems();
  });
});
