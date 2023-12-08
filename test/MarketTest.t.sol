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
        _createAuction();
        assertEq(token.balanceOf(seller), 0);
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
        vm.stopPrank();
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
}
