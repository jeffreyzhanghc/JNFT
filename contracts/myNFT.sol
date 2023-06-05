// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract PersonalInformationNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    /*
    NFT info structure:
    name: name of this NFT
    description: brief description of info stored in this NFT
    owner: owner of the NFT
    allowedBuyers: a mapping that indictaes the NFT buyers(nft holders)
    */
    struct NFTMetadata {
        string name;
        string description;
        address payable owner;
        string personalInfoHash;
    }
    
    mapping(uint256 => NFTMetadata) private _tokenMetadata;
    mapping(uint256 => mapping(address => bool)) private _buyers;
    mapping(uint256 => uint256) private _maxbuyer;
    mapping(uint256 => uint256) private _totalbuyer;
    //uint256 private _totalBuyers;
    uint256 public cost;

    constructor() ERC721("MyInfoNFT", "INFT") {}

    function mintNFT(
        string memory name,
        string memory description,
        string memory personalInfo,
        uint256 maxbuyer
    ) external {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked("ipfs://", Strings.toString(tokenId))));

        string memory personalInfoHash = generateHash(personalInfo);
        NFTMetadata memory metadata = NFTMetadata(name, description, payable(msg.sender),personalInfoHash);
        //pair tokenId with info
        _tokenMetadata[tokenId] = metadata;
        //set this NFT's max num of buyers allowed
        _maxbuyer[tokenId] = maxbuyer;
        //initalize total buyer
        _totalbuyer[tokenId] = 0;
        
        _tokenIdCounter.increment();
    }

    function generateHash(string memory personalInfo) private pure returns (string memory) {
        bytes32 hash = keccak256(bytes(personalInfo));
        return bytes32ToString(hash);
    }

    function buyNFT(uint256 tokenId) external payable{
        require(_exists(tokenId), "NFT does not exist");
        NFTMetadata storage metadata = _tokenMetadata[tokenId];
        require(metadata.owner != address(0), "NFT has no owner");
        require(msg.sender != metadata.owner, "You already own this NFT");
        require(!_buyers[tokenId][msg.sender],"You already bought this NFT");
        require(_maxbuyer[tokenId]>_totalbuyer[tokenId],"Allowed Buyer number has reached limit");
        require(msg.value >= cost, "Insufficient payment");
        metadata.owner.transfer(msg.value);
        
        //add new buyer to the whitelist
        if (!_buyers[tokenId][msg.sender]) {
            _buyers[tokenId][msg.sender] = true;
            _totalbuyer[tokenId]++;
        }
    }

    function getTotalBuyers(uint256 tokenId) external view returns (uint256) {
        require(isOwner(msg.sender,tokenId), "Only owners can access total buyers");
        return _totalbuyer[tokenId];
    }

    function getNFTMetadata(uint256 tokenId) external view returns (NFTMetadata memory) {
        require(_exists(tokenId), "NFT does not exist");
        require(_isAuthorized(msg.sender, tokenId), "Unauthorized access");
        return _tokenMetadata[tokenId];
    }

    function getPersonalInformation(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "NFT does not exist");
        require(isOwner(msg.sender, tokenId), "Unauthorized access");
    }

    function isOwner(address account,uint256 tokenId) public view returns (bool) {
        NFTMetadata storage metadata = _tokenMetadata[tokenId];
        return metadata.owner == account;
    }

    function _isAuthorized(address account, uint256 tokenId) private view returns (bool) {
        return isOwner(account,tokenId) || _buyers[tokenId][msg.sender];
    }
}
