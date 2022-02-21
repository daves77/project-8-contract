//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/utils/Counters.sol";

import "./MarketListing.sol";


contract MarketPlace is MarketListing {
  using Counters for Counters.Counter;

  Counters.Counter private _itemsIds;

  address payable owner;
  uint256 itemListingPrice = 0.001 ether;
  
  constructor() {
    owner = payable(msg.sender);
  }

}