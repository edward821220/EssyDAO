// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Diamond} from "diamond/Diamond.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DAOFactory is Ownable {
    address[] public DAOs;

    constructor(address owner) Ownable(owner) {}

    receive() external payable {}

    fallback() external payable {}

    function createDAO() external returns (address) {}

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
