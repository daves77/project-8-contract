//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public marketplaceAddress;

    constructor(address _marketplaceAddress)
        ERC721("Closed Land Tokens", "CLT")
    {
        marketplaceAddress = _marketplaceAddress;
    }

    event TokenCreated(uint256 newItemId);

    function createToken(string memory tokenURI) public returns (uint256) {
        // increase token id by one to assign to new token
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        console.log("This is your token: %s ", newItemId);

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(marketplaceAddress, true);

        emit TokenCreated(newItemId);
        return newItemId;
    }
}
