// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {SetUp} from "./helper/SetUp.sol";
import {BearNFT, BearToken} from "./helper/Tokens.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {VaultFacet} from "../contracts/facets/optional/VaultFacet.sol";
import {Side} from "../contracts/utils/AppStorage.sol";

contract VaultTest is SetUp {
    DaoFacet dao;
    VaultFacet upgradedDao;

    function setUp() public override {
        super.setUp();

        address daoDiamond = _createDAO();
        dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory vaultCutSelectors = new bytes4[](12);
        vaultCutSelectors[0] = vaultFacet.createCrowdfundingETH.selector;
        vaultCutSelectors[1] = vaultFacet.contributeETH.selector;
        vaultCutSelectors[2] = vaultFacet.withdrawETHByCrowdfunding.selector;
        vaultCutSelectors[3] = vaultFacet.wtihdrawETHByProposal.selector;
        vaultCutSelectors[4] = vaultFacet.createCrowdfundingERC20.selector;
        vaultCutSelectors[5] = vaultFacet.contributeERC20.selector;
        vaultCutSelectors[6] = vaultFacet.withdrawERC20ByCrowdfunding.selector;
        vaultCutSelectors[7] = vaultFacet.withdrawERC20ByProposal.selector;
        vaultCutSelectors[8] = vaultFacet.onERC721Received.selector;
        vaultCutSelectors[9] = vaultFacet.withdrawNFTByOwner.selector;
        vaultCutSelectors[10] = vaultFacet.checkCrowdfundingInfos.selector;
        vaultCutSelectors[11] = vaultFacet.checkCrowdfundingInfo.selector;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(vaultFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: vaultCutSelectors
        });

        // // Use previous block number as proposal snapshot id, so we should go next block.
        vm.roll(block.number + 1);

        uint256 proposalId = dao.createProposal(
            abi.encodeWithSelector(
                diamondCutFacet.diamondCutByProposal.selector,
                cut,
                address(vaultInit),
                abi.encodeWithSignature("init()")
            )
        );
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        dao.executeProposal{value: 0.006 ether}(proposalId);
        upgradedDao = VaultFacet(daoDiamond);
        vm.stopPrank();
    }

    function testCrowdfundingETH() public {
        vm.startPrank(alice);
        vm.expectRevert("You are not the member of the DAO");
        upgradedDao.createCrowdfundingETH("Donate me", 100 ether);
        vm.stopPrank();

        vm.startPrank(founderB);
        uint256 crowdfundingId = upgradedDao.createCrowdfundingETH("Facilitating organizational growth", 8888 ether);
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).title, "Facilitating organizational growth");
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).targetAmount, 8888 ether);
        vm.stopPrank();

        vm.startPrank(founderC);
        vm.expectRevert("Contribution amount must be greater than 0");
        upgradedDao.contributeETH(crowdfundingId);

        uint256 initiatorBalanceBefore = founderB.balance;
        upgradedDao.contributeETH{value: 88 ether}(crowdfundingId);
        uint256 currentAmount = upgradedDao.checkCrowdfundingInfo(crowdfundingId).currentAmount;
        assertEq(currentAmount, 88 ether);
        vm.stopPrank();

        vm.startPrank(founderB);
        upgradedDao.withdrawETHByCrowdfunding(crowdfundingId);
        assertEq(founderB.balance, initiatorBalanceBefore + currentAmount);

        vm.expectRevert("Already withdrawn");
        upgradedDao.withdrawETHByCrowdfunding(crowdfundingId);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("You are not the crowdfunding initiator");
        upgradedDao.withdrawETHByCrowdfunding(crowdfundingId);
        vm.stopPrank();
    }

    function testCrowdfundingERC20() public {
        BearToken token = new BearToken();

        vm.startPrank(alice);
        vm.expectRevert("You are not the member of the DAO");
        upgradedDao.createCrowdfundingERC20("Donate me", address(token), 100 ether);
        vm.stopPrank();

        vm.startPrank(founderB);
        uint256 crowdfundingId =
            upgradedDao.createCrowdfundingERC20("Facilitating organizational growth", address(token), 8888 ether);
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).title, "Facilitating organizational growth");
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).targetAmount, 8888 ether);
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).token, address(token));
        vm.stopPrank();

        deal(address(token), founderC, 88 ether);
        vm.startPrank(founderC);
        vm.expectRevert("Contribution amount must be greater than 0");
        upgradedDao.contributeERC20(crowdfundingId, 0);

        uint256 initiatorBalanceBefore = token.balanceOf(founderB);
        token.approve(address(upgradedDao), type(uint256).max);
        upgradedDao.contributeERC20(crowdfundingId, 88 ether);
        uint256 currentAmount = upgradedDao.checkCrowdfundingInfo(crowdfundingId).currentAmount;
        assertEq(currentAmount, 88 ether);
        vm.stopPrank();

        vm.startPrank(founderB);
        upgradedDao.withdrawERC20ByCrowdfunding(crowdfundingId);
        assertEq(token.balanceOf(founderB), initiatorBalanceBefore + currentAmount);

        vm.expectRevert("Already withdrawn");
        upgradedDao.withdrawERC20ByCrowdfunding(crowdfundingId);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("You are not the crowdfunding initiator");
        upgradedDao.withdrawERC20ByCrowdfunding(crowdfundingId);
        vm.stopPrank();
    }

    function testWithdrawETHByProposal() public {
        vm.startPrank(founderA);
        vm.expectRevert("Only executeProposal function can call this function");
        upgradedDao.wtihdrawETHByProposal(founderB, 88 ether);

        bytes memory data = abi.encodeWithSelector(vaultFacet.wtihdrawETHByProposal.selector, founderB, 88 ether);
        uint256 proposalId = dao.createProposal(data);
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        vm.expectRevert("There is no spare ETH to withdraw");
        dao.executeProposal(proposalId);

        deal(address(upgradedDao), 66 ether);
        vm.expectRevert("Insufficient withdrawable ETH");
        dao.executeProposal(proposalId);

        deal(address(upgradedDao), 88 ether);
        uint256 balanceBefore = founderB.balance;
        dao.executeProposal(proposalId);
        assertEq(founderB.balance, balanceBefore + 88 ether);

        vm.stopPrank();
    }

    function testWithdrawERC20ByProposal() public {
        BearToken token = new BearToken();

        vm.startPrank(founderA);
        vm.expectRevert("Only executeProposal function can call this function");
        upgradedDao.withdrawERC20ByProposal(founderB, address(token), 88 ether);

        bytes memory data =
            abi.encodeWithSelector(vaultFacet.withdrawERC20ByProposal.selector, founderB, address(token), 88 ether);
        uint256 proposalId = dao.createProposal(data);
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        vm.expectRevert("There is no spare tokens to withdraw");
        dao.executeProposal(proposalId);

        deal(address(token), address(upgradedDao), 66 ether);
        vm.expectRevert("Insufficient withdrawable tokens");
        dao.executeProposal(proposalId);

        deal(address(token), address(upgradedDao), 88 ether);
        uint256 balanceBefore = token.balanceOf(founderB);
        dao.executeProposal(proposalId);
        assertEq(token.balanceOf(founderB), balanceBefore + 88 ether);

        vm.stopPrank();
    }

    function testWithdrawNFTByOwner() public {
        vm.startPrank(founderB);

        BearNFT nft = new BearNFT();

        nft.safeTransferFrom(founderB, address(upgradedDao), 88);
        assertEq(nft.balanceOf(address(upgradedDao)), 1);
        assertEq(nft.balanceOf(address(founderB)), 0);

        upgradedDao.withdrawNFTByOwner(address(nft), 88);
        assertEq(nft.balanceOf(address(founderB)), 1);

        nft.safeTransferFrom(founderB, address(upgradedDao), 88);
        vm.stopPrank();

        vm.startPrank(founderA);
        vm.expectRevert("NFT not owned by sender");
        upgradedDao.withdrawNFTByOwner(address(nft), 88);
        vm.stopPrank();
    }
}
