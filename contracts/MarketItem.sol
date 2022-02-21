pragma solidity ^0.8.0;

import "@openzepplin/contracts/utils/Counters.sol"

contract MarketItem {
    using Counters for Counters.Counter;

    Counters.Counter private _itemsIds;

    struct MarketItem {
        uint itemId;
        uint256 tokenId;
        address nftContract;
        address payable seller;
        address payable owner;
        uint32 price;
    }

    mapping(uint256 => MarketItem) marketItemId;
    uint numberOfMarketItems;

    function getUserNFT(address _user) public view return (MarketItem[] memory) {
        for (uint i = 0; i < numberOfMarketItems; i ++ ){
            
        }
    }
}