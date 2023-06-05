// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "foundry.sol";

contract EventNFTTest is Foundry {
    EventNFT private nftContract;
    address private usdcTokenAddress;
    uint256 private tokenPrice;

    function beforeEach() public {
        usdcTokenAddress = address(0x123456789); // Replace with the actual USDC token address
        tokenPrice = 100; // Set the token price
        nftContract = new EventNFT(usdcTokenAddress, tokenPrice);
    }

    function testMintNFT() public {
        // Simulate the approval process
        IERC20 usdcToken = IERC20(usdcTokenAddress);
        usdcToken.transferFrom(msg.sender, address(this), tokenPrice);
        usdcToken.approve(address(nftContract), tokenPrice);

        // Mint a new NFT
        string memory tokenURI = "https://example.com/nft/1";
        uint256 royaltyPercentage = 10;
        nftContract.mintNFT(tokenURI, royaltyPercentage);

        // Assert the NFT details
        uint256 tokenId = 1;
        address creator = address(this);
        string memory storedTokenURI = nftContract.getTokenURI(tokenId);
        uint256 storedRoyaltyPercentage = nftContract.getRoyaltyPercentage(tokenId);

        assert.equal(storedTokenURI, tokenURI, "Invalid token URI");
        assert.equal(storedRoyaltyPercentage, royaltyPercentage, "Invalid royalty percentage");
        assert.equal(nftContract.ownerOf(tokenId), address(this), "Invalid owner");
        assert.equal(nftContract.getCreator(tokenId), creator, "Invalid creator");
    }
}
