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

        bytes4[] memory vaultCutSelectors = new bytes4[](2);
        vaultCutSelectors[0] = vaultFacet.onERC721Received.selector;
        vaultCutSelectors[1] = vaultFacet.withdrawNFTByOwner.selector;

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
