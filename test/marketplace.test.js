const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("market basic functionality", () => {
  let nft;
  let market;
  let nftContractAddress;
  let user1;
  let user2;

  beforeEach(async () => {
    const MarketListing = await ethers.getContractFactory("MarketListing");
    market = await MarketListing.deploy();
    await market.deployed();

    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(market.address);
    await nft.deployed();

    nftContractAddress = nft.address;

    console.log("NFT Contract Address:", nft.address);
    console.log("Marketplace Address:", market.address);

    const users = await ethers.getSigners();
    user1 = users[0];
    user2 = users[1];
    console.log(await user2.getAddress(), "user 2 address");
  });

  it("nft contract should have the market contract address", async () => {
    expect(await nft.marketplaceAddress()).to.equal(market.address);
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

    expect(await nft.tokenURI(1)).to.equal("https://mytokenlocation.com");

    console.log(await nft.tokenURI(1));
  });

  it("can list the item onto the market", async () => {
    console.log("new nft address:", nft.address);
    const userAddress = await user1.getAddress();
    const listingPrice = await market.itemListingPrice();
    const sellingPrice = ethers.utils.parseUnits("3.4", "ether");

    await nft.createToken("https://mytokenlocation.com", {
      from: userAddress,
    });

    expect(
      await market.createMarketItem(nft.address, 1, sellingPrice, {
        value: listingPrice,
        from: userAddress,
      })
    )
      .to.emit(market, "MarketItemCreated")
      .withArgs(
        1,
        1,
        sellingPrice,
        nftContractAddress,
        userAddress,
        ethers.constants.AddressZero,
        false
      );
    // const items = await market.getAllMarketItems();

    // checking that ownership has been transferred to the market
  });

  it("should be able to sell nft", async () => {
    const sellerAddress = await user1.getAddress();
    const buyerAddress = await user2.getAddress();
    const listingPrice = await market.itemListingPrice();
    const sellingPrice = ethers.utils.parseUnits("3.4", "ether");

    await nft.createToken("https://mytokenlocation.com", {
      from: sellerAddress,
    });
    await market.createMarketItem(nft.address, 1, sellingPrice, {
      value: listingPrice,
      from: sellerAddress,
    });

    const items = await market.getAllMarketItems();
    console.log(items);

    expect(
      await market.connect(user2).createMarketItemSale(nft.address, 1, {
        value: sellingPrice,
        from: buyerAddress,
      })
    ).to.emit(market, "MarketItemSold");

    console.log(await market.getAllMarketItems());

    // ensure that actual item has transfered ownership
    expect(await nft.ownerOf(1)).to.equal(buyerAddress);
  });
});
