# CloseLand

## Introduction

CloseLand is a NFT marketplace platform where users can create, buy and trade NFT. The project was completed as part of Rocket Academy Project 5 for 2 weeks.

The technology stack used for our project are as follow:

<ins>Frontend</ins>

1. React.js

<ins>Backend</ins>

1. Express
2. PostgreSQL/Prisma

<ins>Smart Contract & Blockchain Development</ins>

1. Solidity/OpenZeppelin
2. Ethers.js/Hardhat
3. Metamask

## Repositories

<ins>Links to Repositories</ins>

- Frontend: [Link](https://github.com/daves77/bootcamp-project8-react)
- Backend: [Link](https://github.com/bwcee/bootcamp-project8_bckend)
- Backend: [Link](https://github.com/daves77/project-8-contract)

## Usage

<ins>Launch app order</ins>
Clone and launch the app in the following order:

1. Backend
2. Smart Contract
3. Frontend

<ins>Backend Steps</ins>

1. NPM / Yarn Install
2. Setup .env file with the following:

```
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE"
FRONTEND_URL = 'http://localhost:3000'
PORT = 3004

// Example for no password:
// DATABASE_URL="postgresql://username@localhost:5432/nft_backend"
```
3. Run command `npx prisma migrate dev --name init` to create Database and Tables.

4. Run command `nodemon index.js` to start backend server. Keep this running.

<ins>Smart Contract Steps</ins>

1. NPM / Yarn Install
2. Run command `npx hardhat node` to deploy local blockchain. Keep this running. Take note of the 20 dummy accounts created to be incorporated into the metamask section
3. Run command `npx hardhat run --network localhost scripts/deploy.js` to deploy smart contract into our local blockchain. Take note of the deployed MarketListing address and NFT address - checked against Frontend (Step 3 below)
4. An artifacts folder will be created. Copy `artifacts/contracts/MarketPlace.sol/Marketplace.json` & `artifacts/contracts/NFT.sol/NFT.json` into Frontend step 2 below.

<ins>Frontend Steps</ins>

1. NPM / Yarn Install
2. Copy the 2 files in Smart Contracts(Step 4) above into `src/contracts/` folder. Replaced the existing files.
3. Double check `src/contracts/addressSetting.js` address are the same address with Smart Contract (Step 3) above.
4. Head to pinata.cloud to setup an account to obtain the PINATA API KEY & PINATA API SECRET. Setup .env file with the following:

```
REACT_APP_PINATA_KEY='YOUR_PINATA_KEY'
REACT_APP_PINATA_SECRET='YOUR_PINATA_SECRET'
```

5. Run command `npm run start` to launch the app.

<ins>MetaMask</ins>

1. [Guide](https://devtonight.com/posts/metamask-testnet-wallet-setup-for-blockchain-development#:~:text=Add%20Custom%20Testnet%20Networks%20To,%2C%20RPC%20URL%2C%20chain%20ID) to create metamask and connect to localhost.
2. Connect your metamask wallet to localhost with the following config:

```
Network Name: Hardhat

New RPC URL: http://localhost:8545

Chain ID: 1337
```

3. In metamask, select the option to "Import Account" and paste the private keys of one of those accounts (in Smart Contract - step 2) from the local hardhat node - to connect metamask to that account in order to use it.
4. Start creating and trading your NFT on the website!
