// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract DutchAuction is Ownable {

    struct Offer {
        address seller;
        uint256 offerPrice;
        uint256 auctionEnd;
        bytes encryptedData; // Placeholder for encrypted address/GPS etc.
        bool finalized;
    }

    struct Bid {
        address bidder;
        uint256 amount;
        bool revealed;
    }

    uint256 public nextOfferId = 1;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => mapping(address => Bid)) public bids;

    IERC20 public acceptedToken; // ERC20 token for payments

    constructor(address _tokenAddress) {
        acceptedToken = IERC20(_tokenAddress);
    }

    function createOffer(uint256 price, uint256 duration, bytes memory encryptedData) external returns (uint256) {
        uint256 offerId = nextOfferId;
        offers[offerId] = Offer({
            seller: msg.sender,
            offerPrice: price,
            auctionEnd: block.timestamp + duration,
            encryptedData: encryptedData,
            finalized: false
        });
        nextOfferId = nextOfferId + 1;
        return offerId;
    }

    function placeBid(uint256 offerId, uint256 amount) external {
        require(offers[offerId].auctionEnd > block.timestamp, "Auction has ended");
        require(acceptedToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        bids[offerId][msg.sender] = Bid({
            bidder: msg.sender,
            amount: amount,
            revealed: false
        });
    }

    function finalizeAuction(uint256 offerId) external {
        require(offers[offerId].auctionEnd <= block.timestamp, "Auction still ongoing");
        require(!offers[offerId].finalized, "Auction already finalized");

        Offer storage offer = offers[offerId];

        address winner = address(0);
        uint256 highestBid = 0;

        // Simplified winner determination: the highest bid that matches or exceeds the offer price
        for (address bidderAddress = address(0); ; ) {
            Bid storage bid = bids[offerId][bidderAddress];
            if (bid.amount > highestBid && bid.amount >= offer.offerPrice) {
                highestBid = bid.amount;
                winner = bidderAddress;
            }
            // Move to the next bidder in a real-world implementation

            if (bidderAddress == address(0)) break; // Exit condition, replace with a proper one in a real-world scenario
        }

        if (winner != address(0)) {
            // Transfer the payment to the seller
            acceptedToken.transfer(offer.seller, highestBid);
            // Implement further logic to handle winner data and possibly refund other bidders
        }

        offer.finalized = true;
    }

    // ... Other functions like withdraw for sellers, refund for non-winning bidders, etc.

}
