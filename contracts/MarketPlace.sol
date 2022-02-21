//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzepplin/contracts/token/ERC721/.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzepplin/contracts/security/ReentrancyGuard.sol";

contract MarketPlace is ReentrancyGuard {
  using Counters for Counters.Counter;

  Counters.Counter private _itemsIds;

  address payable owner;
  uint32 itemListingPrice = 0.001 ether;
      // arrange variables of the same type together to
      // save gas
  struct MarketItem {
      uint256 itemId;
      uint256 tokenId;
      uint256 price;
      address nftContract;
      address payable seller;
      address payable owner;
      bool sold;
  }

  mapping(uint256 => MarketItem) private marketItemId;


  function listMarketItem() public payable nonRentrant  {

  }

}