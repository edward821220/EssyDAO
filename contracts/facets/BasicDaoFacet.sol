// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AppStorage, Side, Proposal, Status} from "../utils/AppStorage.sol";

contract BasicDaoFacet is ERC20 {
    AppStorage internal s;

    uint256 constant CREATE_PROPOSAL_MIN_SHARES = 100 * 10 ** 18;
    uint256 constant VOTING_PERIOD = 7 days;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function createProposal(bytes32 proposalHash_) external {
        require(balanceOf(msg.sender) >= CREATE_PROPOSAL_MIN_SHARES, "No enough shares");
        require(s.proposals[proposalHash_].proposalHash == bytes32(0), "Proposal already exists");
        s.proposals[proposalHash_] = Proposal({
            author: msg.sender,
            proposalHash: proposalHash_,
            createdAt: block.timestamp,
            votesYes: 0,
            votesNo: 0,
            status: Status.Pending
        });
    }

    function vote(bytes32 proposalHash_, Side side_) external {
        require(s.isVoted[msg.sender][proposalHash_] == false, "Already voted");
        require(s.proposals[proposalHash_].status == Status.Pending, "Proposal is not pending");
        require(block.timestamp - s.proposals[proposalHash_].createdAt <= VOTING_PERIOD, "Voting period is over");

        s.isVoted[msg.sender][proposalHash_] = true;
        Proposal storage proposal = s.proposals[proposalHash_];
        if (side_ == Side.Yes) {
            proposal.votesYes += balanceOf(msg.sender);
            if (proposal.votesYes * 100 / totalSupply() > 50) {
                proposal.status = Status.Approved;
            }
        } else {
            proposal.votesNo += balanceOf(msg.sender);
            if (proposal.votesNo * 100 / totalSupply() > 50) {
                proposal.status = Status.Rejected;
            }
        }
    }
}
