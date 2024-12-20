// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INFTAuction {
    struct Auction {
        address seller;
        address nftAddress;
        uint256 tokenId;
        address paymentToken;
        uint256 minPrice;
        uint256 maxPrice;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool claimed;
    }

    event AuctionCreated(uint256 auctionId, address indexed seller);
    event BidPlaced(uint256 auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address indexed winner);

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        address _paymentToken,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _startTime,
        uint256 _endTime
    ) external;

    function placeBid(uint256 auctionId, uint256 amount) external;

    function claimNFT(uint256 auctionId) external;
}
