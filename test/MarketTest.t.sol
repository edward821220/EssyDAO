// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Market} from "../contracts/Market.sol";
import {BearToken} from "./helper/Tokens.sol";

contract MarketTest is Test {
    uint256 constant AUCTION_DURATION = 7 days;

    Market market;
    BearToken token;

    address admin = makeAddr("Admin");
    address seller = makeAddr("Seller");
    address buyer1 = makeAddr("Buyer1");
    address buyer2 = makeAddr("Buyer2");

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

    event FixedSaleCompleted(uint256 indexed saleId, address indexed buyer, uint256 amount);

    function setUp() public {
        vm.startPrank(admin);
        market = new Market();
        vm.stopPrank();

        vm.startPrank(seller);
        token = new BearToken();
        vm.stopPrank();

        deal(buyer1, 100 ether);
        deal(buyer2, 100 ether);
    }

    function testCreateAuction() public {
        uint256 auctionId = _createAuction();

        assertEq(token.balanceOf(seller), 0);
        assertEq(market.checkAuction(address(token), auctionId).startPrice, 0.0008 ether);
        assertEq(market.checkAuction(address(token), auctionId).endTime, block.timestamp + AUCTION_DURATION);
        assertEq(market.checkAuction(address(token), auctionId).seller, seller);
        assertEq(market.checkAuction(address(token), auctionId).highestBidder, address(0));
        assertEq(market.checkAuction(address(token), auctionId).highestBid, 0.0008 ether);
    }

    function testBid() public {
        uint256 auctionId = _createAuction();

        vm.startPrank(buyer1);
        vm.expectRevert("Bid not high enough");
        market.bid{value: 0.0006 ether}(address(token), auctionId);

        vm.expectEmit(true, true, true, true);
        emit Bid(auctionId, buyer1, 0.001 ether);
        market.bid{value: 0.001 ether}(address(token), auctionId);
        vm.stopPrank();

        vm.startPrank(buyer2);
        vm.expectRevert("Bid not high enough");
        market.bid{value: 0.001 ether}(address(token), auctionId);

        vm.expectEmit(true, true, true, true);
        emit Bid(auctionId, buyer2, 0.002 ether);
        market.bid{value: 0.002 ether}(address(token), auctionId);

        vm.warp(block.timestamp + AUCTION_DURATION);
        vm.expectRevert("Auction already ended");
        market.bid{value: 0.005 ether}(address(token), auctionId);

        assertEq(market.checkAuction(address(token), auctionId).highestBid, 0.002 ether);
        assertEq(market.checkAuction(address(token), auctionId).highestBidder, buyer2);

        vm.stopPrank();
    }

    function testEndAuctionWithBuyer() public {
        uint256 auctionId = _createAuction();

        vm.startPrank(buyer1);

        market.bid{value: 0.001 ether}(address(token), auctionId);

        vm.expectRevert("Auction not yet ended");
        market.endAuction(address(token), auctionId);

        vm.warp(block.timestamp + AUCTION_DURATION);
        vm.expectEmit(true, true, true, true);
        emit AuctionEnded(auctionId, buyer1, 0.001 ether);
        market.endAuction(address(token), auctionId);
        assertEq(token.balanceOf(buyer1), 8888 ether);

        vm.expectRevert("Auction end already called");
        market.endAuction(address(token), auctionId);

        vm.stopPrank();
    }

    function testEndAuctionWithoutBuyer() public {
        uint256 auctionId = _createAuction();

        vm.startPrank(seller);

        vm.warp(block.timestamp + AUCTION_DURATION);
        vm.expectEmit(true, true, true, true);
        emit AuctionEnded(auctionId, address(0), 0.0008 ether);
        market.endAuction(address(token), auctionId);
        assertEq(token.balanceOf(seller), 8888 ether);

        vm.stopPrank();
    }

    function testCreateFixedSale() public {
        uint256 auctionId = _createFixedSale();

        assertEq(token.balanceOf(seller), 0);
        assertEq(market.checkFixedSale(address(token), auctionId).pricePerToken, 100 gwei);
        assertEq(market.checkFixedSale(address(token), auctionId).seller, seller);
        assertEq(address(market.checkFixedSale(address(token), auctionId).token), address(token));
        assertEq(market.checkFixedSale(address(token), auctionId).tokenAmount, 8888 ether);
        assertEq(market.checkFixedSale(address(token), auctionId).soldAmount, 0);
    }

    function _createAuction() private returns (uint256 auctionId) {
        vm.startPrank(seller);
        token.approve(address(market), type(uint256).max);
        vm.expectEmit(true, true, true, true);
        emit AuctionCreated(
            1, seller, address(token), token.balanceOf(seller), 0.0008 ether, block.timestamp + AUCTION_DURATION
        );
        auctionId = market.createAuction(address(token), token.balanceOf(seller), 0.0008 ether);
        vm.stopPrank();
    }

    function _createFixedSale() private returns (uint256 auctionId) {
        vm.startPrank(seller);
        token.approve(address(market), type(uint256).max);
        vm.expectEmit(true, true, true, true);
        emit FixedSaleCreated(1, seller, address(token), token.balanceOf(seller), 100 gwei);
        auctionId = market.createFixedSale(address(token), token.balanceOf(seller), 100 gwei);
        vm.stopPrank();
    }
}
