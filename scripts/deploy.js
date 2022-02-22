/* 
1. ref syntax for deploying multiple contracts from stackoverflow (ref a below)
2. even tho we haf ethers installed... ethers obtained from hardhat is diff... getContractFactory and getSigners is a method in ethers from hardhat... not e orig ethers... 
Refs
a. How to deploy multiple smart contracts using hardhat-deploy: https://stackoverflow.com/questions/69812460/how-to-deploy-multiple-smart-contracts-using-hardhat-deploy
b. Deploying your contracts: https://hardhat.org/guides/deploying.html#deploying-your-contracts
c. Testing with ethers.js & Waffle: https://hardhat.org/guides/waffle-testing.html
*/
const { ethers } = require("hardhat");

async function main() {
  /* 
  1. nxt 2 lines not in official hardhat docs (ref b above), but just to get deployer address 
  */
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts w account: ${deployer.address}`);

  /* 
  1. frm ref c,  MarketListing below shld be a contractFactory from ethers.js
  2. tt's why able to MarketListing.deploy(), which is a contractFactory method from ethers.js
  3. market is the contract returned frm MarketListing contractFactory  
  4. NFT.deploy(market.address) has a parameter passed in cos the nft contract has a constructor which is expecting an address
  5. not really sure if market.deployed() and nft.deployed() required... it's in v4 ethers.js docs tt "the Contract may not be mined immediately. The contract.deployed() function will return a Promise which will resolve once the contract is deployed, or reject if there was an error during deployment." (https://docs.ethers.io/v4/api-contract.html)  
  6. nil mention of pt 5 above in latest ethers.js docs (https://docs.ethers.io/v5/api/contract/contract-factory/#ContractFactory-deploy)
  7. think no harm to leave them in?
  */
  const MarketListing = await ethers.getContractFactory("MarketListing");
  const market = await MarketListing.deploy();
  await market.deployed();

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(market.address);
  await nft.deployed();

  console.log("MarketListing deployed to:", market.address);
  console.log("NFT deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
