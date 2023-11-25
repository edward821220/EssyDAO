// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum Side {
    Yes,
    No
}

enum Status {
    Pending,
    Approved,
    Rejected,
    Finished
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

struct DAOInfo {
    address daoAddress;
    string daoName;
}

struct FounderInfo {
    address founder;
    uint256 shares;
}

struct Receiver {
    address receiver;
    uint256 amount;
}

struct AppStorage {
    address diamond;
    string daoName;
    string tokenName;
    string symbol;
    uint256 totalSupply;
    mapping(address account => uint256) balances;
    mapping(address account => mapping(address spender => uint256)) allowances;
    Proposal[] proposals;
    mapping(address => mapping(uint256 => bool)) isVoted;
}
