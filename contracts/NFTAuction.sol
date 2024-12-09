// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTAuction is Ownable {
    struct Auction {
        address nftContract;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 minPrice;
        uint256 maxPrice;
        address currentHighestBidder;
        uint256 currentHighestBid;
        bool active;
        address paymentToken; // ERC-20 token for payment
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCounter;

    event AuctionCreated(
        uint256 auctionId,
        address nftContract,
        uint256 tokenId
    );
    event BidPlaced(uint256 auctionId, address bidder, uint256 bidAmount);
    event AuctionConcluded(
        uint256 auctionId,
        address winner,
        uint256 finalPrice
    );

    constructor() Ownable(msg.sender) {
        auctionCounter = 0;
    }

    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minPrice,
        uint256 _maxPrice,
        address _paymentToken
    ) public onlyOwner {
        require(_endTime > _startTime, "Invalid end time");
        require(_minPrice < _maxPrice, "Invalid price range");

        auctionCounter++;
        auctions[auctionCounter] = Auction({
            nftContract: _nftContract,
            tokenId: _tokenId,
            startTime: _startTime,
            endTime: _endTime,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            currentHighestBidder: address(0),
            currentHighestBid: 0,
            active: true,
            paymentToken: _paymentToken
        });

        emit AuctionCreated(auctionCounter, _nftContract, _tokenId);
    }

    function placeBid(uint256 _auctionId, uint256 _bidAmount) public {
        Auction storage auction = auctions[_auctionId];
        IERC20 paymentToken = IERC20(auction.paymentToken);

        require(
            block.timestamp >= auction.startTime &&
                block.timestamp <= auction.endTime,
            "Auction not active"
        );
        require(
            _bidAmount >= auction.minPrice && _bidAmount <= auction.maxPrice,
            "Invalid bid amount"
        );
        require(_bidAmount > auction.currentHighestBid, "Bid must be higher");

        // Transfer tokens from bidder to contract
        require(
            paymentToken.transferFrom(msg.sender, address(this), _bidAmount),
            "Token transfer failed"
        );

        // Refund previous highest bidder
        if (auction.currentHighestBidder != address(0)) {
            require(
                paymentToken.transfer(
                    auction.currentHighestBidder,
                    auction.currentHighestBid
                ),
                "Refund failed"
            );
        }

        // Update auction details
        auction.currentHighestBidder = msg.sender;
        auction.currentHighestBid = _bidAmount;

        emit BidPlaced(_auctionId, msg.sender, _bidAmount);
    }

    function concludeAuction(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        IERC20 paymentToken = IERC20(auction.paymentToken);

        require(block.timestamp > auction.endTime, "Auction not ended");
        require(auction.active, "Auction already concluded");

        // Transfer NFT to highest bidder
        if (auction.currentHighestBidder != address(0)) {
            IERC721(auction.nftContract).transferFrom(
                owner(),
                auction.currentHighestBidder,
                auction.tokenId
            );

            // Transfer bid tokens to NFT owner
            require(
                paymentToken.transfer(owner(), auction.currentHighestBid),
                "Payment transfer failed"
            );

            emit AuctionConcluded(
                _auctionId,
                auction.currentHighestBidder,
                auction.currentHighestBid
            );
        }

        auction.active = false;
    }

    // Optional: Withdraw function for unclaimed auction tokens
    function withdrawTokens(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Withdrawal failed");
    }
}
