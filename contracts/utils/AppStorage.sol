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
    Finished,
    Cancelled
}

struct Proposal {
    uint256 id;
    address author;
    uint256 createdAt;
    uint256 votesYes;
    uint256 votesNo;
    bytes data;
    Status status;
    uint256 snapshotId;
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

struct Snapshots {
    uint256[] ids;
    uint256[] values;
}

struct Dividend {
    uint256 snapshopId;
    uint256 startTime;
    uint256 duration;
    uint256 annualRate;
}

struct CrowdfundingInfo {
    address crowdfundingInitiator;
    string title;
    address token;
    uint256 targetAmount;
    uint256 currentAmount;
    uint256 withdrawnAmount;
}

struct AppStorage {
    // Dao Facet
    address diamond;
    string daoName;
    string tokenName;
    string symbol;
    uint256 totalSupply;
    mapping(address account => uint256) balances;
    mapping(address account => mapping(address spender => uint256)) allowances;
    Proposal[] proposals;
    mapping(address account => mapping(uint256 => bool)) isVoted;
    mapping(address => Snapshots) accountBalanceSnapshots;
    Snapshots totalSupplySnapshots;
    // Dividend Facet
    uint256 dividendTimes;
    Dividend dividendInfo;
    mapping(address account => mapping(uint256 dividendTimes => uint256)) tokenReleased;
    // Vault Facet
    CrowdfundingInfo[] crowdfundingInfos;
    uint256 totalETHByFunding;
    mapping(address token => uint256) totalTokensByFunding;
    mapping(address owner => mapping(address contractAddress => mapping(uint256 tokenId => bool))) NFTOwners;
}
