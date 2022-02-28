//had to delete import references to Marketplace.sol for compilation to be successful

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";
import "./Marketplace.sol";

contract MarketListing is ReentrancyGuard, Marketplace {
    using Counters for Counters.Counter;

    Counters.Counter internal _itemsId;
    Counters.Counter internal _tradeId;

    struct MarketItem {
        uint256 itemId; // keeps track of all items ever listed
        uint256 tokenId; //should be universal to all ERC721 contracts (notsure)
        uint256 price; // price users wants to list token at
        address nftContract; // contract where NFT is minted
        address payable seller; // person who is listing NFT
        address payable owner; // empty by default until sold
        string status;
    }

    struct MarketTradeOffer {
        uint256 tradeId;
        uint256[] offererItemsId;
        uint256[] offereeItemsId;
        address offerer; // person making the offer
        address offeree; // person receiving the offer
        bool closed;
    }

    // keeps track of all items ever listed
    mapping(uint256 => MarketItem) internal marketItemId;
    mapping(uint256 => MarketTradeOffer) internal marketTradeId;

    event MarketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address indexed nftContract,
        address seller,
        address owner,
        string status
    );

    event MarketItemSold(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address indexed nftContract
    );

    event MarketTradeCreated(
        uint256 tradeId,
        uint256[] offererItemsId,
        uint256[] offereeItemsId,
        address offerer,
        address offeree,
        bool closed
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
            "available"
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
            "available"
        );
    }

    /**
     * @dev Retrieves all items that have been listed on the marketplace
     */
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

    /**
     * @dev Creates a direct sale if the seller has an open listing
     */
    function createMarketItemSale(address _nftContract, uint256 _itemId)
        public
        payable
        nonReentrant
    {
        MarketItem storage soldItem = marketItemId[_itemId];
        uint256 price = soldItem.price;
        uint256 tokenId = soldItem.tokenId;

        //ensure that buyer sent enough eth to buy NFT
        require(msg.value == price, "Not enough ETH for puchase");
        require(
            keccak256(bytes(soldItem.status)) == keccak256(bytes("available")),
            "Item is no longer available"
        );

        // transfer eth from buyer to seller
        soldItem.seller.transfer(msg.value);

        // transfer ownership to buyer
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);

        // update blockchain
        soldItem.owner = payable(msg.sender);
        soldItem.status = "sold";
        // payable(_owner).transfer(itemListingPrice);
        emit MarketItemSold(_itemId, tokenId, price, _nftContract);
    }

    function createItemTradeOffer(
        uint256[] memory _offererItemId,
        uint256[] memory _offereeItemId,
        address _offeree
    ) public nonReentrant {
        for (uint256 i = 0; i < _offererItemId.length; i++) {
            MarketItem memory item = marketItemId[_offererItemId[i]];
            require(item.seller == msg.sender, "offerer not owner of these");
        }
        for (uint256 i = 0; i < _offereeItemId.length; i++) {
            MarketItem memory item = marketItemId[_offereeItemId[i]];
            require(item.seller == _offeree, "offeree not owner of these");
        }
        _tradeId.increment();
        uint256 tradeId = _tradeId.current();
        console.log("%s tradeId", tradeId);
        marketTradeId[tradeId] = MarketTradeOffer(
            tradeId,
            _offererItemId,
            _offereeItemId,
            msg.sender,
            _offeree,
            false
        );

        emit MarketTradeCreated(
            tradeId,
            _offererItemId,
            _offereeItemId,
            msg.sender,
            _offeree,
            false
        );
    }

    function approveTradeOffer() public nonReentrant {}
}
