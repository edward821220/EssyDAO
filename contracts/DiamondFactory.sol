// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Diamond} from "../contracts/Diamond.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {FounderInfo, DAOInfo} from "./utils/AppStorage.sol";

contract DiamondFactory is Ownable {
    DAOInfo[] public DAOs;

    event DAOCreated(address indexed daoAddress, address indexed founder, string indexed daoName);

    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    fallback() external payable {}

    function createDAODiamond(
        string memory daoName,
        FounderInfo[] memory foundersInfo,
        string memory tokenName,
        string memory tokenSymbol,
        address diamondCutFacet,
        address diamondLoupeFacet,
        address daoFacet,
        address daoInit
    ) external returns (address) {
        bytes32 salt_ = keccak256(abi.encodePacked(daoName, msg.sender));

        Diamond diamond = new Diamond{salt: salt_}(
            msg.sender,
            daoName,
            foundersInfo,
            tokenName,
            tokenSymbol,
            diamondCutFacet,
            diamondLoupeFacet,
            daoFacet,
            daoInit
        );

        DAOs.push(DAOInfo(address(diamond), daoName));

        emit DAOCreated(address(diamond), msg.sender, daoName);

        return address(diamond);
    }

    function getDAO(uint256 index) external view returns (DAOInfo memory) {
        return DAOs[index];
    }

    function getDAOs() external view returns (DAOInfo[] memory) {
        return DAOs;
    }

    function withdraw() external onlyOwner {
        (bool success,) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }
}
