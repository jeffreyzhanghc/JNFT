// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ApprovalContract {
    IERC20 public usdcToken;
    address public nftContract;
    uint256 public approvalAmount;

    constructor(address _usdcToken, address _nftContract, uint256 _approvalAmount) {
        usdcToken = IERC20(_usdcToken);
        nftContract = _nftContract;
        approvalAmount = _approvalAmount;
    }

    function approveTokenTransfer() external {
        require(usdcToken.allowance(msg.sender, address(this)) == 0, "Already approved");

        // Approve the NFT contract to transfer the USDC tokens
        usdcToken.approve(nftContract, approvalAmount);
    }
}
