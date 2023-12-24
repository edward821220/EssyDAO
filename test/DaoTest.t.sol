// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SetUp} from "./helper/SetUp.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {Proposal, Side, Status, Receiver} from "../contracts/utils/AppStorage.sol";

contract DaoTest is SetUp {
    event ProposalCreated(uint256 indexed proposalId, string indexed proposalType, string indexed description);

    function setUp() public override {
        super.setUp();
    }

    function testCreateProposal() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(alice);
        vm.expectRevert("No enough shares to create proposal");
        dao.createProposal(new bytes(0), "Other", "Test proposal");
        vm.stopPrank();

        vm.startPrank(founderA);
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(1, "Other", "Test proposal");
        uint256 proposalId = dao.createProposal(new bytes(0), "Other", "Test proposal");
        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(proposalId, 1);
        assertEq(proposal.id, proposalId);
        assertEq(proposal.author, founderA);
        assertEq(proposal.snapshotId, block.number - 1);
        assertEq(uint256(proposal.status), uint256(Status.Pending));
        assertEq(dao.getProposals().length, 1);
        vm.stopPrank();
    }

    function testCancelProposal() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        uint256 proposalId = dao.createProposal(new bytes(0), "Other", "Test proposal");
        vm.stopPrank();

        vm.startPrank(founderB);
        vm.expectRevert("Only author can cancel proposal");
        dao.cancelProposal(proposalId);
        vm.stopPrank();

        vm.startPrank(founderA);
        dao.cancelProposal(proposalId);
        assertEq(uint256(dao.checkProposal(proposalId).status), uint256(Status.Cancelled));
        vm.stopPrank();

        vm.startPrank(founderB);
        vm.expectRevert("Proposal is cancelled");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();
    }

    function testVote() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        // // Use previous block number as proposal snapshot id, so we should go next block.
        vm.roll(block.number + 1);

        vm.startPrank(founderA);
        uint256 proposalId = dao.createProposal(new bytes(0), "Other", "Test proposal");
        dao.vote(proposalId, Side.Yes);
        vm.expectRevert("Already voted");
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.No);
        assertEq(dao.checkIsVoted(proposalId), true);
        dao.transfer(alice, 100 ether);
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert("You didn't have enough shares at the block before proposal created");
        dao.vote(proposalId, Side.Yes);
        dao.transfer(founderB, 100 ether);
        vm.stopPrank();

        vm.startPrank(founderC);
        dao.vote(proposalId, Side.Yes);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        Proposal memory proposal = dao.checkProposal(proposalId);
        assertEq(
            proposal.votesYes,
            dao.balanceOfAt(founderA, proposal.snapshotId) + dao.balanceOfAt(founderC, proposal.snapshotId)
        );
        assertEq(proposal.votesNo, dao.balanceOfAt(founderB, proposal.snapshotId));
        assertEq(uint256(proposal.status), uint256(Status.Approved));

        vm.startPrank(bob);
        vm.warp(block.timestamp + 7 days);
        deal(daoDiamond, bob, 100 ether);
        vm.expectRevert("Voting period is over");
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();
    }

    function testMintByProposal(uint256 amountA, uint256 amountAlice, uint256 amountBob) public {
        vm.assume(amountA <= 8888 ether);
        vm.assume(amountAlice <= 8888 ether);
        vm.assume(amountBob <= 8888 ether);

        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        uint256 previousBalanceA = dao.balanceOf(founderA);
        uint256 previousBalanceAlice = dao.balanceOf(alice);
        uint256 previousBalanceBob = dao.balanceOf(bob);
        uint256 previousSupply = dao.totalSupply();

        Receiver[] memory receivers = new Receiver[](3);
        receivers[0] = Receiver(founderA, amountA);
        receivers[1] = Receiver(alice, amountAlice);
        receivers[2] = Receiver(bob, amountBob);

        vm.expectRevert("Only executeProposal function can call this function");
        dao.mintByProposal(receivers);

        // // Use previous block number as proposal snapshot id, so we should go next block.
        vm.roll(block.number + 1);

        vm.startPrank(founderA);
        uint256 proposalId =
            dao.createProposal(abi.encodeWithSelector(dao.mintByProposal.selector, receivers), "Mint", "Test proposal");
        vm.expectRevert("Proposal is not approved");
        dao.executeProposal(proposalId);
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        dao.executeProposal(proposalId);
        vm.stopPrank();

        assertEq(dao.totalSupply(), previousSupply + amountA + amountAlice + amountBob);
        assertEq(dao.balanceOf(founderA), previousBalanceA + amountA);
        assertEq(dao.balanceOf(alice), previousBalanceAlice + amountAlice);
        assertEq(dao.balanceOf(bob), previousBalanceBob + amountBob);
        assertEq(uint256(dao.checkProposal(proposalId).status), uint256(Status.Finished));
    }
}
