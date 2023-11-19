// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Diamond} from "../contracts/Diamond.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DiamondFactory is Ownable {
    address[] public DAOs;

    event DAOCreated(address indexed daoAddress, address indexed founder);

    constructor(address owner) Ownable(owner) {}

    receive() external payable {}

    fallback() external payable {}

    function createDAODiamond(
        string calldata DAOName,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _diamondCutFacet,
        address _diamondLoupeFacet,
        address _basicDaoFacet,
        address _basicDaoInit
    ) external returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(DAOName, msg.sender));

        Diamond diamond =
        new Diamond{salt: _salt}(msg.sender, _tokenName, _tokenSymbol, _diamondCutFacet, _diamondLoupeFacet, _basicDaoFacet, _basicDaoInit);

        emit DAOCreated(address(diamond), msg.sender);

        return address(diamond);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
