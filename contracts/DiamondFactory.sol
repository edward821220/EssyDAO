// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Diamond} from "../contracts/Diamond.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DiamondFactory is Ownable {
    address[] public DAOs;

    event DAOCreated(address indexed daoAddress, address indexed founder);

    constructor(address owner) Ownable(owner) {}

    receive() external payable {}

    fallback() external payable {}

    function createDaoDiamond(string calldata name_) external returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(name_, msg.sender));
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        Diamond diamond = new Diamond{salt: _salt}(msg.sender, address(diamondCutFacet));
        emit DAOCreated(address(diamond), msg.sender);
        return address(diamond);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
