//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract MarketListing is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemsId;

    uint256 public listingPrice = 0.01 ether;

    struct MarketItem {
        // autoincrement of item id to index the items that have
        // been listed on the marketplace
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address nftContract;
        address payable seller;
        address payable owner;
        bool sold;
    }

    mapping(uint256 => MarketItem) private marketItemId;

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
        require(_price > 0, "Can't set price to be less than 0");

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

    function getAllMarketItems() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemsId.current();
        console.log("total items: %s", totalItems);
        MarketItem[] memory items = new MarketItem[](totalItems);

        for (uint256 i = 0; i < totalItems; i++) {
            //not sure if this will work
            uint256 currentId = marketItemId[i + 1].itemId;
            MarketItem storage currentItem = marketItemId[currentId];
            items[i] = currentItem;
        }

        return items;
    }
}
