// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DaoFacet is ERC20 {
    enum Side {
        Yes,
        No
    }
    enum Status {
        Pending,
        Approved,
        Rejected
    }

    struct Proposal {
        address author;
        bytes32 proposalHash;
        uint256 createdAt;
        uint256 votesYes;
        uint256 votesNo;
        Status status;
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(address => mapping(bytes32 => bool)) public isVoted;

    uint256 constant CREATE_PROPOSAL_MIN_SHARES = 100 * 10 ** 18;
    uint256 constant VOTING_PERIOD = 7 days;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function createProposal(bytes32 proposalHash_) external {
        require(balanceOf(msg.sender) >= CREATE_PROPOSAL_MIN_SHARES, "No enough shares");
        require(proposals[proposalHash_].proposalHash == bytes32(0), "Proposal already exists");
        proposals[proposalHash_] = Proposal({
            author: msg.sender,
            proposalHash: proposalHash_,
            createdAt: block.timestamp,
            votesYes: 0,
            votesNo: 0,
            status: Status.Pending
        });
    }

    function vote(bytes32 proposalHash_, Side side_) external {
        require(isVoted[msg.sender][proposalHash_] == false, "Already voted");
        require(proposals[proposalHash_].status == Status.Pending, "Proposal is not pending");
        require(block.timestamp - proposals[proposalHash_].createdAt <= VOTING_PERIOD, "Voting period is over");

        isVoted[msg.sender][proposalHash_] = true;
        Proposal storage proposal = proposals[proposalHash_];
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
