//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// didnt inherit from Ownable due to some issues regarding payable
// might resolve later
contract Marketplace {
    address payable public _owner;
    uint256 public itemListingPrice = 0.001 ether;

    constructor() {
        _owner = payable(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setListingPrice(uint256 _price) external onlyOwner {
        itemListingPrice = _price;
    }
}
