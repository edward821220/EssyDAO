// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

struct AppStorage {
    mapping(bytes32 => Proposal) proposals;
    mapping(address => mapping(bytes32 => bool)) isVoted;
}
