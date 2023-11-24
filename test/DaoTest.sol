// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BasicSetup} from "./helper/BasicSetup.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {AppStorage, FounderInfo, Proposal, Side, Status, Receiver} from "../contracts/utils/AppStorage.sol";

contract DaoTest is BasicSetup {
    function setUp() public override {
        super.setUp();
    }

    function testCreateProposal() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(alice);
        vm.expectRevert("No enough shares to create proposal");
        dao.createProposal(new bytes(0));
        vm.stopPrank();

        vm.startPrank(founder1);
        uint256 proposalId = dao.createProposal(new bytes(0));
        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(proposalId, 1);
        assertEq(proposal.id, proposalId);
        assertEq(proposal.author, founder1);
        assertEq(uint256(proposal.status), uint256(Status.Pending));
        vm.stopPrank();
    }

    function testVote() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(founder1);
        uint256 proposalId = dao.createProposal(new bytes(0));
        dao.vote(proposalId, Side.Yes);
        vm.expectRevert("Already voted");
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(founder2);
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert("You are not the member of the DAO");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founder3);
        dao.vote(proposalId, Side.Yes);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(proposal.votesYes, dao.balanceOf(founder1) + dao.balanceOf(founder3));
        assertEq(proposal.votesNo, dao.balanceOf(founder2));
        assertEq(uint256(proposal.status), uint256(Status.Approved));

        vm.startPrank(bob);
        vm.warp(block.timestamp + 7 days);
        deal(daoDiamond, bob, 100 ether);
        vm.expectRevert("Voting period is over");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();
    }

    // function testExecuteProposal() public {
    //  Receiver[] memory receivers = new Receiver[](2);
    // receivers[0] = Receiver(founder1, 300 ether);
    // receivers[0] = Receiver(alice, 100 ether);
    // receivers[0] = Receiver(bob, 100 ether);
    //     vm.startPrank(founder1);
    //     address diamond = factory.createDAODiamond(
    //         "EasyDAO",
    //         foundersInfo,
    //         "Goverence Token",
    //         "GOV",
    //         address(diamondCutFacet),
    //         address(diamondLoupeFacet),
    //         address(daoFacet),
    //         address(daoInit)
    //     );
    //     DaoFacet dao = DaoFacet(diamond);
    //     IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

    //     bytes4[] memory ownershipCutSelectors = new bytes4[](2);
    //     ownershipCutSelectors[0] = ownershipFacet.transferOwnership.selector;
    //     ownershipCutSelectors[1] = ownershipFacet.owner.selector;
    //     cut[0] = IDiamondCut.FacetCut({
    //         facetAddress: address(ownershipFacet),
    //         action: IDiamondCut.FacetCutAction.Add,
    //         functionSelectors: ownershipCutSelectors
    //     });

    //     uint256 proposalId = dao.createProposal(
    //         abi.encodeWithSelector(
    //             diamondCutFacet.diamondCutByProposal.selector,
    //             ++s.proposalCount,
    //             cut,
    //             address(ownershipInit),
    //             abi.encodeWithSignature("init(address)", founder2)
    //         )
    //     );
    //     dao.vote(proposalId, Side.Yes);
    //     assertEq(dao.checkIsVoted(proposalId), true);
    //     vm.stopPrank();

    //     vm.startPrank(founder2);
    //     dao.vote(proposalId, Side.Yes);
    //     assertEq(dao.checkIsVoted(proposalId), true);
    //     assertEq(uint256(dao.checkProposal(proposalId).status), 1);
    //     dao.executeProposal(proposalId);
    //     OwnershipFacet upgradedDao = OwnershipFacet(diamond);
    //     assertEq(upgradedDao.owner(), founder2);
    //     vm.stopPrank();
    // }
}
