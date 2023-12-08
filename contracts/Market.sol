// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Market is ReentrancyGuard {
    struct Auction {
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 startPrice;
        uint256 endTime;
        IERC20 token;
        uint256 tokenAmount;
        bool ended;
    }

    uint256 constant AUCTION_DURATION = 7 days;

    mapping(address token => Auction[]) public auctions;

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 startPrice,
        uint256 endTime
    );

    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 bid);

    event AuctionEnded(uint256 indexed auctionId, address winner, uint256 highestBid);

    function createAuction(address tokenAddress_, uint256 tokenAmount_, uint256 startPrice_) external {
        require(tokenAmount_ > 0, "Token amount must be greater than zero");

        IERC20 token_ = IERC20(tokenAddress_);
        require(token_.transferFrom(msg.sender, address(this), tokenAmount_), "Token transfer failed");

        auctions[tokenAddress_].push(
            Auction({
                seller: msg.sender,
                highestBidder: address(0),
                highestBid: startPrice_,
                startPrice: startPrice_,
                endTime: block.timestamp + AUCTION_DURATION,
                token: token_,
                tokenAmount: tokenAmount_,
                ended: false
            })
        );

        emit AuctionCreated(
            auctions[tokenAddress_].length,
            msg.sender,
            tokenAddress_,
            tokenAmount_,
            startPrice_,
            block.timestamp + AUCTION_DURATION
        );
    }

    function bid(address tokenAddress_, uint256 auctionId_) external payable nonReentrant {
        Auction storage auction = auctions[tokenAddress_][auctionId_ - 1];

        require(block.timestamp < auction.endTime, "Auction already ended");
        require(msg.value > auction.highestBid, "Bid not high enough");

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        emit BidPlaced(auctionId_, msg.sender, msg.value);
    }

    function endAuction(address tokenAddress_, uint256 auctionId_) external nonReentrant {
        Auction storage auction = auctions[tokenAddress_][auctionId_ - 1];

        require(block.timestamp >= auction.endTime, "Auction not yet ended");
        require(!auction.ended, "Auction end already called");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            auction.token.transfer(auction.highestBidder, auction.tokenAmount);
            payable(auction.seller).transfer(auction.highestBid);
        } else {
            auction.token.transfer(auction.seller, auction.tokenAmount);
        }

        emit AuctionEnded(auctionId_, auction.highestBidder, auction.highestBid);
    }
}
