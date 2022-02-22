//had to delete import references to Marketplace.sol for compilation to be successful

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract MarketListing is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter internal _itemsId;
    uint256 public listingPrice = 0.01 ether;

    struct MarketItem {
        uint256 itemId; // keeps track of all items ever listed
        uint256 tokenId; //should be universal to all ERC721 contracts (notsure)
        uint256 price; // price users wants to list token at
        address nftContract; // contract where NFT is minted
        address payable seller; // person who is listing NFT
        address payable owner; // empty by default until sold
        bool sold;
    }

    // keeps track of all items ever listed
    mapping(uint256 => MarketItem) internal marketItemId;

    event MarketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address indexed nftContract,
        address seller,
        address owner,
        bool sold
    );

    function createMarketItem(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Can't set price > 0");

        _itemsId.increment();
        uint256 itemId = _itemsId.current();
        console.log("created market item with id: %s", itemId);
        marketItemId[itemId] = MarketItem(
            itemId,
            _tokenId,
            _price,
            _nftContract,
            payable(msg.sender),
            payable(address(0)),
            false
        );

        // transfer ownership from seller to contract
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        emit MarketItemCreated(
            itemId,
            _tokenId,
            _price,
            _nftContract,
            payable(msg.sender),
            address(0),
            false
        );
    }

    /**
     * @dev Retrieves all items that have been listed on the marketplace
     */
    function getAllMarketItems() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemsId.current();
        console.log("total items: %s", totalItems);
        MarketItem[] memory items = new MarketItem[](totalItems);

        for (uint256 i = 1; i < totalItems; i++) {
            //not sure if this will work
            uint256 currentId = marketItemId[i].itemId;
            MarketItem storage currentItem = marketItemId[currentId];
            items[i] = currentItem;
        }

        return items;
    }

    function closeMarketItem(address _nftContract, uint256 _itemId)
        public
        payable
        nonReentrant
    {
        // tbc
    }
}
