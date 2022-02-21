//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
    
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    address public contractAddress;

    constructor(address marketplaceAddress) ERC721("test tokens", "TTT") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns(uint) {
        console.log("This is your token: %s ", tokenURI);
        // increase token id by one to assign to new token
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);

        return newItemId;
    }
}