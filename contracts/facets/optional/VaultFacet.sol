// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {AppStorage, CrowdfundingInfo} from "../../utils/AppStorage.sol";

contract VaultFacet is IERC721Receiver {
    AppStorage s;

    function createCrowdfundingETH(string calldata title, uint256 amount) external returns (uint256) {
        require(s.balances[msg.sender] > 0, "You are not the member of the DAO");
        s.crowdfundingInfos.push(CrowdfundingInfo({crowdfundingInitiator: msg.sender, title: title, amount: amount}));
        return s.crowdfundingInfos.length;
    }

    function contributeETH(uint256 crowdfundingId) external payable {
        require(msg.value > 0, "Contribution amount must be greater than 0");
        s.crowdfundingInfos[crowdfundingId].amount += msg.value;
    }

    function withdrawETHByCrowdFunding(uint256 crowdfundingId) external {
        require(
            msg.sender == s.crowdfundingInfos[crowdfundingId].crowdfundingInitiator,
            "You are not the crowd funding initiator"
        );
        uint256 amount = s.crowdfundingInfos[crowdfundingId].amount;
        payable(msg.sender).transfer(amount);
    }

    function wtihdrawETHByProposal(address to, uint256 amount) external {
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");
        payable(to).transfer(amount);
    }

    function withdrawERC20ByProposal(address to, address ERC20Contract, uint256 amount) external {
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");
        IERC20(ERC20Contract).transfer(to, amount);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns (bytes4) {
        // Allow members to safeTransfer NFT in and record who owns this NFT
        s.NFTOwners[from][msg.sender][tokenId] = true;
        return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawNFTByOwner(address NFTContract, uint256 tokenId) external {
        require(s.NFTOwners[msg.sender][NFTContract][tokenId], "NFT not owned by sender");
        IERC721(NFTContract).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
