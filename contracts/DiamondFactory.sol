// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Diamond} from "../contracts/Diamond.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {FounderInfo} from "./utils/AppStorage.sol";

contract DiamondFactory is Ownable {
    address[] public DAOs;

    event DAOCreated(address indexed daoAddress, address indexed founder);

    constructor(address owner) Ownable(owner) {}

    receive() external payable {}

    fallback() external payable {}

    function createDAODiamond(
        string calldata daoName,
        FounderInfo[] calldata foundersInfo,
        string calldata tokenName,
        string calldata tokenSymbol,
        address diamondCutFacet,
        address diamondLoupeFacet,
        address daoFacet,
        address daoInit
    ) external returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(daoName, msg.sender));

        Diamond diamond =
        new Diamond{salt: _salt}(msg.sender,foundersInfo, tokenName, tokenSymbol, diamondCutFacet, diamondLoupeFacet, daoFacet, daoInit);

        DAOs.push(address(diamond));
        emit DAOCreated(address(diamond), msg.sender);
        return address(diamond);
    }

    function getDAO(uint256 index) external view returns (address) {
        return DAOs[index];
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
