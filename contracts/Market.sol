// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Market is ReentrancyGuard {
    struct Auction {
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 startPrice;
        uint256 endTime;
        ERC20 token;
        uint256 tokenAmount;
        bool ended;
    }

    struct FixedSale {
        address seller;
        uint256 pricePerToken;
        ERC20 token;
        uint256 tokenAmount;
        uint256 soldAmount;
        bool canceled;
    }

    mapping(address token => Auction[]) public auctions;
    mapping(address token => FixedSale[]) public fixedSales;

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed tokenAddress,
        uint256 tokenAmount,
        uint256 startPrice,
        uint256 endTime
    );

    event Bid(uint256 indexed auctionId, address indexed bidder, uint256 indexed bid);

    event AuctionEnded(uint256 indexed auctionId, address indexed winner, uint256 indexed highestBid);

    event FixedSaleCreated(
        uint256 indexed saleId, address indexed seller, address indexed tokenAddress, uint256 tokenAmount, uint256 price
    );

    event FixedSaleCanceled(address indexed tokenAddress, uint256 indexed saleId);

    event FixedSaleCompleted(
        address indexed tokenAddress, uint256 indexed saleId, address indexed buyer, uint256 amount
    );

    // Auction
    function createAuction(address tokenAddress_, uint256 tokenAmount_, uint256 startPrice_, uint256 duration)
        external
        returns (uint256 auctionId)
    {
        require(tokenAmount_ > 0, "Token amount must be greater than zero");

        ERC20 token_ = ERC20(tokenAddress_);
        token_.transferFrom(msg.sender, address(this), tokenAmount_);

        auctions[tokenAddress_].push(
            Auction({
                seller: msg.sender,
                highestBidder: address(0),
                highestBid: startPrice_,
                startPrice: startPrice_,
                endTime: block.timestamp + duration,
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
            block.timestamp + duration
        );

        return auctions[tokenAddress_].length;
    }

    function cancelAuction(address tokenAddress_, uint256 auctionId_) external nonReentrant {
        Auction storage auction = auctions[tokenAddress_][auctionId_ - 1];
        require(msg.sender == auction.seller, "Only the seller can cancel the auction");
        require(block.timestamp < auction.endTime && !auction.ended, "Auction already ended");
        require(auction.highestBidder == address(0), "Someone has already placed a bid");
        auctions[tokenAddress_][auctionId_ - 1].ended = true;
        auction.token.transfer(auction.seller, auction.tokenAmount);
        emit AuctionEnded(auctionId_, auction.highestBidder, auction.highestBid);
    }

    function bid(address tokenAddress_, uint256 auctionId_) external payable nonReentrant {
        Auction storage auction = auctions[tokenAddress_][auctionId_ - 1];

        require(block.timestamp < auction.endTime && !auction.ended, "Auction already ended");
        require(msg.value > auction.highestBid, "Bid not high enough");

        if (auction.highestBidder != address(0)) {
            (bool success,) = payable(auction.highestBidder).call{value: auction.highestBid}("");
            require(success, "Failed to send ETH to previous highest bidder");
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        emit Bid(auctionId_, msg.sender, msg.value);
    }

    function endAuction(address tokenAddress_, uint256 auctionId_) external nonReentrant {
        Auction storage auction = auctions[tokenAddress_][auctionId_ - 1];

        require(block.timestamp >= auction.endTime, "Auction not yet ended");
        require(!auction.ended, "Auction already ended");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            auction.token.transfer(auction.highestBidder, auction.tokenAmount);
            (bool success,) = payable(auction.seller).call{value: auction.highestBid}("");
            require(success, "Failed to send ETH to seller");
        } else {
            auction.token.transfer(auction.seller, auction.tokenAmount);
        }

        emit AuctionEnded(auctionId_, auction.highestBidder, auction.highestBid);
    }

    function checkAuctions(address tokenAddress) external view returns (Auction[] memory) {
        return auctions[tokenAddress];
    }

    function checkAuction(address tokenAddress, uint256 auctionId) external view returns (Auction memory) {
        return auctions[tokenAddress][auctionId - 1];
    }

    // Fixed Sale
    function createFixedSale(address tokenAddress_, uint256 tokenAmount_, uint256 pricePerToken_)
        external
        returns (uint256 saleId)
    {
        fixedSales[tokenAddress_].push(
            FixedSale({
                seller: msg.sender,
                pricePerToken: pricePerToken_,
                token: ERC20(tokenAddress_),
                tokenAmount: tokenAmount_,
                soldAmount: 0,
                canceled: false
            })
        );

        ERC20(tokenAddress_).transferFrom(msg.sender, address(this), tokenAmount_);

        emit FixedSaleCreated(fixedSales[tokenAddress_].length, msg.sender, tokenAddress_, tokenAmount_, pricePerToken_);

        return fixedSales[tokenAddress_].length;
    }

    function cancelFixedSale(address tokenAddress_, uint256 saleId_) external nonReentrant {
        FixedSale storage sale = fixedSales[tokenAddress_][saleId_ - 1];
        require(msg.sender == sale.seller, "Only the seller can cancel the auction");
        require(!sale.canceled, "Sale already canceled");

        uint256 repayAmount = sale.tokenAmount - sale.soldAmount;
        require(repayAmount > 0, "No enough tokens left");
        sale.canceled = true;
        sale.token.transfer(msg.sender, repayAmount);

        emit FixedSaleCanceled(tokenAddress_, saleId_);
    }

    function buyFixedSale(address tokenAddress_, uint256 saleId_, uint256 tokenAmount_) external payable nonReentrant {
        FixedSale storage sale = fixedSales[tokenAddress_][saleId_ - 1];
        require(!sale.canceled, "Sale already canceled");
        require(sale.soldAmount + tokenAmount_ <= sale.tokenAmount, "No enough tokens left");
        require(
            msg.value == sale.pricePerToken * tokenAmount_ / (10 ** ERC20(tokenAddress_).decimals()), "Incorrect value"
        );

        sale.soldAmount += tokenAmount_;

        sale.token.transfer(msg.sender, sale.tokenAmount);
        (bool success,) = payable(sale.seller).call{value: msg.value}("");
        require(success, "Failed to send ETH to seller");

        emit FixedSaleCompleted(tokenAddress_, saleId_, msg.sender, tokenAmount_);
    }

    function checkFixedSales(address tokenAddress) external view returns (FixedSale[] memory) {
        return fixedSales[tokenAddress];
    }

    function checkFixedSale(address tokenAddress, uint256 saleId) external view returns (FixedSale memory) {
        return fixedSales[tokenAddress][saleId - 1];
    }
}
