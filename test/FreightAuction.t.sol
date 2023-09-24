// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/DutchAuction.sol";
import "../src/mock/MockUSDC.sol";
import "forge-std/Test.sol";

contract DutchAuctionTest is Test {
    DutchAuction public auction;
    MockUSDC public usdc;

    function setUp() public {
        usdc = new MockUSDC();
        usdc.mint(address(this), 1000000000000);  // minting 1M USDC for testing
        auction = new DutchAuction(address(usdc));
    }

    function testCreateOffer() public {
        bytes memory encryptedData = new bytes(32); // Dummy encrypted data
        uint256 offerId = auction.createOffer(100, 3600, encryptedData);
        (address seller, uint256 offerPrice, uint256 auctionEnd, bytes memory data, bool finalized) = auction.offers(offerId);
        
        assertEq(seller, address(this));
        assertEq(offerPrice, 100);
        assertEq(data, encryptedData);
    }

    function testPlaceBid() public {
        bytes memory encryptedData = new bytes(32); // Dummy encrypted data
        uint256 offerId = auction.createOffer(100, 3600, encryptedData);
        
        // For simplicity, let's assume the test account (this contract) has enough tokens for bidding
        usdc.approve(address(auction), 105);  // approving 105 tokens for auction contract
        auction.placeBid(offerId, 105);

        (address bidder, uint256 amount, bool revealed) = auction.bids(offerId, address(this));
        
        assertEq(bidder, address(this));
        assertEq(amount, 105);
        assertFalse(revealed);  // ensuring bid hasn't been revealed
    }

    function testFinalizeAuction() public {
        bytes memory encryptedData = new bytes(32); // Dummy encrypted data
        uint256 duration = 10;  // 10 seconds
        uint256 offerId = auction.createOffer(100, duration, encryptedData);  // short duration for testing
        
        // Placing a bid
        usdc.approve(address(auction), 105);
        auction.placeBid(offerId, 105);
        
        // fast forward the test blockchain's time by duration + 1 second
        vm.warp(block.timestamp + duration + 1);
        auction.finalizeAuction(offerId);
        
        (address seller, uint256 offerPrice, uint256 auctionEnd, bytes memory data, bool finalized) = auction.offers(offerId);
        
        assertTrue(finalized);
        // Additional assertions on balance transfers and other auction results could be added
    }
}
