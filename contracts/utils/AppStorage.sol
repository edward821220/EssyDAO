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
    uint256 id;
    address author;
    uint256 createdAt;
    uint256 votesYes;
    uint256 votesNo;
    bytes data;
    Status status;
}

struct AppStorage {
    address diamond;
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(address account => uint256) balances;
    mapping(address account => mapping(address spender => uint256)) allowances;
    uint256 proposalCount;
    mapping(uint256 => Proposal) proposals;
    mapping(address => mapping(uint256 => bool)) isVoted;
}
