// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {AppStorage, CrowdfundingInfo} from "../../utils/AppStorage.sol";

contract VaultFacet is IERC721Receiver {
    AppStorage s;

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function createCrowdfundingETH(string calldata title, uint256 amount) external returns (uint256) {
        require(s.balances[msg.sender] > 0, "You are not the member of the DAO");
        s.crowdfundingInfos.push(CrowdfundingInfo(msg.sender, title, ETH, amount, 0, 0));
        return s.crowdfundingInfos.length - 1;
    }

    function contributeETH(uint256 crowdfundingId) external payable {
        require(msg.value > 0, "Contribution amount must be greater than 0");
        s.crowdfundingInfos[crowdfundingId].currentAmount += msg.value;
        s.totalETHByFunding += msg.value;
    }

    function withdrawETHByCrowdfunding(uint256 crowdfundingId) external {
        CrowdfundingInfo memory crowdfundingInfo = checkCrowdfundingInfo(crowdfundingId);

        require(msg.sender == crowdfundingInfo.crowdfundingInitiator, "You are not the crowdfunding initiator");

        uint256 amount = crowdfundingInfo.currentAmount - crowdfundingInfo.withdrawnAmount;
        require(amount > 0, "Already withdrawn");

        crowdfundingInfo.withdrawnAmount += amount;
        s.crowdfundingInfos[crowdfundingId] = crowdfundingInfo;
        payable(msg.sender).transfer(amount);
    }

    function createCrowdfundingERC20(string calldata title, address token, uint256 amount) external returns (uint256) {
        require(s.balances[msg.sender] > 0, "You are not the member of the DAO");
        s.crowdfundingInfos.push(CrowdfundingInfo(msg.sender, title, token, amount, 0, 0));
        return s.crowdfundingInfos.length - 1;
    }

    function contributeERC20(uint256 crowdfundingId, uint256 amount) external {
        require(amount > 0, "Contribution amount must be greater than 0");
        CrowdfundingInfo memory crowdfundingInfo = checkCrowdfundingInfo(crowdfundingId);
        address token = crowdfundingInfo.token;
        require(IERC20(token).balanceOf(msg.sender) >= amount, "You don't have enough tokens");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        s.crowdfundingInfos[crowdfundingId].currentAmount += amount;
        s.totalTokensByFunding[token] += amount;
    }

    function withdrawERC20ByCrowdfunding(uint256 crowdfundingId) external {
        CrowdfundingInfo memory crowdfundingInfo = checkCrowdfundingInfo(crowdfundingId);

        require(msg.sender == crowdfundingInfo.crowdfundingInitiator, "You are not the crowdfunding initiator");

        uint256 amount = crowdfundingInfo.currentAmount - crowdfundingInfo.withdrawnAmount;
        require(amount > 0, "Already withdrawn");

        crowdfundingInfo.withdrawnAmount += amount;
        s.crowdfundingInfos[crowdfundingId] = crowdfundingInfo;

        address token = crowdfundingInfo.token;
        IERC20(token).transfer(msg.sender, amount);
    }

    // Accidentally received ETH or ERC20 can be transferred out through a Proposal.
    function wtihdrawETHByProposal(address to, uint256 amount) external {
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");

        uint256 balanceETH = address(this).balance;
        uint256 fundingETH = s.totalETHByFunding;
        require(balanceETH > fundingETH, "There is no spare ETH to withdraw");
        require(balanceETH - fundingETH >= amount, "Insufficient withdrawable ETH");
        payable(to).transfer(amount);
    }

    function withdrawERC20ByProposal(address to, address token, uint256 amount) external {
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");

        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 funding = s.totalTokensByFunding[token];
        require(balance > funding, "There is no spare tokens to withdraw");
        require(balance - funding >= amount, "Insufficient withdrawable tokens");
        IERC20(token).transfer(to, amount);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns (bytes4) {
        // Allow members to safeTransfer NFT in and record who owns this NFT
        s.NFTOwners[from][msg.sender][tokenId] = true;
        return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawNFTByOwner(address NFTContract, uint256 tokenId) external {
        require(s.NFTOwners[msg.sender][NFTContract][tokenId], "NFT not owned by sender");
        s.NFTOwners[msg.sender][NFTContract][tokenId] = false;
        IERC721(NFTContract).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function checkCrowdfundingInfos() public view returns (CrowdfundingInfo[] memory) {
        return s.crowdfundingInfos;
    }

    function checkCrowdfundingInfo(uint256 crowdfundingId) public view returns (CrowdfundingInfo memory) {
        return s.crowdfundingInfos[crowdfundingId];
    }
}
