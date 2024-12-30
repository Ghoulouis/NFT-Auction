// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTAuction {
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

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

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
    ) external {
        require(_endTime > _startTime, "Invalid time range");

        IERC721(_nftAddress).transferFrom(msg.sender, address(this), _tokenId);
        auctions[auctionCount] = Auction({
            seller: msg.sender,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            paymentToken: _paymentToken,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            startTime: _startTime,
            endTime: _endTime,
            highestBidder: address(0),
            highestBid: 0,
            claimed: false
        });

        emit AuctionCreated(auctionCount, msg.sender);
        auctionCount++;
    }

    function placeBid(uint256 auctionId, uint256 amount) external {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp >= auction.startTime, "Auction not started");
        require(block.timestamp <= auction.endTime, "Auction ended");
        require(amount >= auction.minPrice, "Bid too low");
        require(amount > auction.highestBid, "Bid not higher");

        IERC20(auction.paymentToken).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (auction.highestBidder != address(0)) {
            IERC20(auction.paymentToken).transfer(
                auction.highestBidder,
                auction.highestBid
            );
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = amount;

        emit BidPlaced(auctionId, msg.sender, amount);
    }

    function claimNFT(uint256 auctionId) external {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp > auction.endTime, "Auction not ended");
        require(!auction.claimed, "NFT already claimed");

        if (auction.highestBidder != address(0)) {
            IERC721(auction.nftAddress).transferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenId
            );
            IERC20(auction.paymentToken).transfer(
                auction.seller,
                auction.highestBid
            );
        } else {
            IERC721(auction.nftAddress).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
        }

        auction.claimed = true;
        emit AuctionEnded(auctionId, auction.highestBidder);
    }
}
