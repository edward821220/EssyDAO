// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BasicSetup} from "./helper/BasicSetup.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {Proposal, Side, Status, Receiver} from "../contracts/utils/AppStorage.sol";

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

        vm.startPrank(founderA);
        uint256 proposalId = dao.createProposal(new bytes(0));
        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(proposalId, 1);
        assertEq(proposal.id, proposalId);
        assertEq(proposal.author, founderA);
        assertEq(uint256(proposal.status), uint256(Status.Pending));
        vm.stopPrank();
    }

    function testVote() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        uint256 proposalId = dao.createProposal(new bytes(0));
        dao.vote(proposalId, Side.Yes);
        vm.expectRevert("Already voted");
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert("You are not the member of the DAO");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderC);
        dao.vote(proposalId, Side.Yes);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(proposal.votesYes, dao.balanceOf(founderA) + dao.balanceOf(founderC));
        assertEq(proposal.votesNo, dao.balanceOf(founderB));
        assertEq(uint256(proposal.status), uint256(Status.Approved));

        vm.startPrank(bob);
        vm.warp(block.timestamp + 7 days);
        deal(daoDiamond, bob, 100 ether);
        vm.expectRevert("Voting period is over");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();
    }

    function testMintByProposal() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);
        uint256 previousBalanceA = dao.balanceOf(founderA);
        uint256 previousSupply = dao.totalSupply();

        Receiver[] memory receivers = new Receiver[](3);
        receivers[0] = Receiver(founderA, 300 ether);
        receivers[1] = Receiver(alice, 200 ether);
        receivers[2] = Receiver(bob, 100 ether);

        vm.expectRevert("Only executeProposal function can call this function");
        dao.mintByProposal(receivers);

        vm.startPrank(founderA);
        uint256 proposalId = dao.createProposal(abi.encodeWithSelector(dao.mintByProposal.selector, receivers));
        vm.expectRevert("Proposal is not approved");
        dao.executeProposal(proposalId);
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        dao.executeProposal(proposalId);
        vm.stopPrank();

        assertEq(dao.totalSupply(), previousSupply + 600 ether);
        assertEq(dao.balanceOf(founderA), previousBalanceA + 300 ether);
        assertEq(dao.balanceOf(alice), 200 ether);
        assertEq(dao.balanceOf(bob), 100 ether);
        assertEq(uint256(dao.checkProposal(proposalId).status), uint256(Status.Finished));
    }
}
