// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INFTShop {
    struct Listing {
        address nftContract;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
        bool active;
    }

    event NFTListed(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );

    event NFTSold(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );

    function initialize(address admin) external;

    function listNFT(
        address nftContract,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    ) external;

    function buyNFT(uint256 listingId) external payable;
}
