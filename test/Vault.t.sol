// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {BasicSetup} from "./helper/BasicSetup.sol";
import {BearNFT, BearToken} from "./helper/Tokens.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {VaultFacet} from "../contracts/facets/optional/VaultFacet.sol";
import {Side} from "../contracts/utils/AppStorage.sol";

contract VaultTest is BasicSetup {
    DaoFacet dao;
    VaultFacet upgradedDao;

    function setUp() public override {
        super.setUp();

        address daoDiamond = _createDAO();
        dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory vaultCutSelectors = new bytes4[](8);
        vaultCutSelectors[0] = vaultFacet.checkCrowdfundingInfo.selector;
        vaultCutSelectors[1] = vaultFacet.createCrowdfundingETH.selector;
        vaultCutSelectors[2] = vaultFacet.contributeETH.selector;
        vaultCutSelectors[3] = vaultFacet.withdrawETHByCrowdFunding.selector;
        vaultCutSelectors[4] = vaultFacet.wtihdrawETHByProposal.selector;
        vaultCutSelectors[5] = vaultFacet.createCrowdfundingERC20.selector;
        vaultCutSelectors[6] = vaultFacet.onERC721Received.selector;
        vaultCutSelectors[7] = vaultFacet.withdrawNFTByOwner.selector;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(vaultFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: vaultCutSelectors
        });

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
        assertEq(upgradedDao.checkCrowdfundingInfo(crowdfundingId).currentAmount, 88 ether);
        vm.stopPrank();

        vm.startPrank(founderB);
        upgradedDao.withdrawETHByCrowdFunding(crowdfundingId);
        assertEq(founderB.balance, initiatorBalanceBefore + 88 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("You are not the crowd funding initiator");
        upgradedDao.withdrawETHByCrowdFunding(crowdfundingId);
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
