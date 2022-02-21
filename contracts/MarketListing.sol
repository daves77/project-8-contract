//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MarketListing is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemsId;

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

    mapping(uint256 => MarketItem) marketItemId;


    event MarketItemCreated (
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

        marketItemId[itemId] = MarketItem(
            itemId,
            _tokenId,
            _price,
            _nftContract,
            payable(msg.sender),
            payable(address(0)),
            false
        );

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
}