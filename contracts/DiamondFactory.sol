// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Diamond} from "diamond/Diamond.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DiamondFactory is Ownable {
    address[] public DAOs;

    event DAOCreated(address indexed daoAddress, address indexed founder);

    constructor(address owner) Ownable(owner) {}

    receive() external payable {}

    fallback() external payable {}

    function createDiamond() external returns (string memory name) {
        bytes32 _salt = keccak256(abi.encodePacked(name, msg.sender));
        Diamond diamond = new Diamond{salt: _salt}(msg.sender, address(1));
        emit DAOCreated(address(diamond), msg.sender);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
