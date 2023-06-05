// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract EventNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address private _usdcAddress;
    uint256 private _price;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _tokenCreators;
    mapping(uint256 => uint256) private _royalties;
    mapping(uint256 => bool) private _isReserved;
    mapping(uint256 => address) private _reservationAddress;

    event TicketReserved(uint256 indexed tokenId, address indexed reservationAddress);

    constructor(address usdcAddress, uint256 price) ERC721("EventNFT", "ENFT") {
        _usdcAddress = usdcAddress;
        _price = price;
    }

    function mintNFT(string memory tokenURI, uint256 royaltyPercentage) external {
        //check allowance
        require(IERC20(_usdcAddress).allowance(msg.sender, address(this)) >= _price, "Insufficient allowance");
        //make USDC transform
        require(IERC20(_usdcAddress).transferFrom(msg.sender, address(this), _price), "Payment failed");
        //increment token_id
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        //mint nft andd set URI
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        _tokenCreators[newTokenId] = msg.sender;
        _royalties[newTokenId] = royaltyPercentage;
        _isReserved[newTokenId] = false;
    }

    function setPrice(uint256 price) external {
        _price = price;
    }

    function getPrice() external view returns (uint256) {
        return _price;
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) external {
        require(_exists(tokenId), "Token does not exist");
        require(msg.sender == ownerOf(tokenId) || msg.sender == getApproved(tokenId), "Not authorized");

        _tokenURIs[tokenId] = tokenURI;
    }

    function getTokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        return _tokenURIs[tokenId];
    }

    function getCreator(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "Token does not exist");

        return _tokenCreators[tokenId];
    }

    function getRoyaltyPercentage(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");

        return _royalties[tokenId];
    }

    function setRoyaltyPercentage(uint256 tokenId, uint256 royaltyPercentage) external {
        require(_exists(tokenId), "Token does not exist");
        require(msg.sender == ownerOf(tokenId), "Not authorized");

        _royalties[tokenId] = royaltyPercentage;
    }

    function reserveTicket(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        require(!_isReserved[tokenId], "Ticket already reserved");

        _isReserved[tokenId] = true;
        _reservationAddress[tokenId] = msg.sender;

        emit TicketReserved(tokenId, msg.sender);
    }

    function isTicketReserved(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Token does not exist");

        return _isReserved[tokenId];
    }

    function getReservationAddress(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        require(_isReserved[tokenId], "Ticket not reserved");

        return _reservationAddress[tokenId];
    }
}

