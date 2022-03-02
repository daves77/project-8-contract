//had to delete import references to Marketplace.sol for compilation to be successful

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";
import "./MarketPlace.sol";

contract MarketListing is ReentrancyGuard, Marketplace {
    using Counters for Counters.Counter;

    Counters.Counter internal _itemsId;
    Counters.Counter internal _tradeId;

    struct MarketItem {
        uint256 itemId; // keeps track of all items ever listed
        uint256 tokenId; //should be universal to all ERC721 contracts (notsure)
        uint256 price; // price users wants to list token at
        address nftContract; // contract where NFT is minted
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
        soldItem.owner.transfer(msg.value);

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
            require(item.owner == msg.sender, "offerer not owner of these");
        }
        for (uint256 i = 0; i < _offereeItemId.length; i++) {
            MarketItem memory item = marketItemId[_offereeItemId[i]];
            require(item.owner == _offeree, "offeree not owner of these");
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

    function getUserTradeOffers(address _user)
        public
        view
        returns (MarketTradeOffer[] memory)
    {
        uint256 totalTrades = _tradeId.current();
        uint256 userTrades = 0;
        for (uint256 i = 0; i < totalTrades; i++) {
            if (
                marketTradeId[i + 1].offeree == _user ||
                marketTradeId[i + 1].offerer == _user
            ) {
                userTrades += 1;
            }
        }

        uint256 counter = 0;
        MarketTradeOffer[] memory trades = new MarketTradeOffer[](userTrades);
        for (uint256 i = 0; i < totalTrades; i++) {
            MarketTradeOffer memory currentTrade = marketTradeId[i + 1];
            if (currentTrade.offeree == _user) {
                trades[counter] = currentTrade;
                counter += 1;
            }
        }
        return trades;
    }

    function approveTradeOffer(uint256 _tradeOfferId, address _nftContract)
        public
        nonReentrant
    {
        MarketTradeOffer storage currentTrade = marketTradeId[_tradeOfferId];
        require(
            currentTrade.offeree == msg.sender,
            "this offer is not available"
        );

        //transfer offerer item to oferree
        for (uint256 i = 0; i < currentTrade.offererItemsId.length; i++) {
            MarketItem storage item = marketItemId[
                currentTrade.offererItemsId[i]
            ];
            //update user
            item.owner = payable(msg.sender);
            item.status = "traded";
            IERC721(_nftContract).transferFrom(
                address(this),
                msg.sender,
                item.tokenId
            );
        }

        //transfer offeree item to oferrer
        for (uint256 i = 0; i < currentTrade.offereeItemsId.length; i++) {
            MarketItem storage item = marketItemId[
                currentTrade.offereeItemsId[i]
            ];
            //update item owner
            item.owner = payable(currentTrade.offerer);
            item.status = "traded";
            IERC721(_nftContract).transferFrom(
                address(this),
                currentTrade.offerer,
                item.tokenId
            );
        }

        currentTrade.closed = true;
    }
}
