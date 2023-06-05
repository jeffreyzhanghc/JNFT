// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "foundry/contracts/FoundryTest.sol";
import "./PersonalInformationNFT.sol";

contract PersonalInformationNFTTest is FoundryTest {
    PersonalInformationNFT private nftContract;
    
    function beforeEach() public override {
        nftContract = new PersonalInformationNFT();
    }
    
    function createNFT(string memory name, string memory description, string memory personalInfo, uint256 maxbuyer) internal {
        nftContract.mintNFT(name, description, personalInfo, maxbuyer);
    }
    
    function buyNFT(uint256 tokenId) internal payable {
        nftContract.buyNFT{value: msg.value}(tokenId);
    }
    
    function testNFTCreation() public {
        createNFT("NFT1", "Description1", "Personal Info 1", 5);
        
        uint256 tokenId = 0; // Update with the correct tokenId
        
        assert(nftContract.ownerOf(tokenId) == address(this), "Incorrect NFT owner");
        assert(nftContract.getTotalBuyers(tokenId) == 0, "Incorrect initial total buyers");
    }
    
    function testBuyNFT() public payable {
        createNFT("NFT2", "Description2", "Personal Info 2", 3);
        
        uint256 tokenId = 0; // Update with the correct tokenId
        
        buyNFT(tokenId);
        assert(nftContract.getTotalBuyers(tokenId) == 1, "Incorrect total buyers after first purchase");
        
        // Attempt to buy again
        bool success;
        (success, ) = address(nftContract).call{value: msg.value}(abi.encodeWithSignature("buyNFT(uint256)", tokenId));
        assert(!success, "Should not be able to buy NFT again");
    }
    
    function testAccessPersonalInformation() public {
        createNFT("NFT3", "Description3", "Personal Info 3", 2);
        
        uint256 tokenId = 0; // Update with the correct tokenId
        
        bool success;
        string memory personalInfo;
        
        (success, personalInfo) = address(nftContract).call(abi.encodeWithSignature("getPersonalInformation(uint256)", tokenId));
        assert(!success, "Should not be able to access personal information without ownership");
        
        buyNFT(tokenId);
        
        (success, personalInfo) = address(nftContract).call(abi.encodeWithSignature("getPersonalInformation(uint256)", tokenId));
        assert(success, "Failed to access personal information");
        assert(bytes(personalInfo).length > 0, "Personal information is empty");
    }
}
