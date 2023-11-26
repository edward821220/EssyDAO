// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../utils/LibDiamond.sol";
import {AppStorage} from "../utils/AppStorage.sol";

contract DiamondCutFacet is IDiamondCut {
    AppStorage internal s;

    // The owner of the contract is set to 0 after the contract is initialized until the members of the DAO upgrade the Ownership feature through a proposal. Before that, any feature upgrades must use the diamondCutByProposal function.
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external payable {
        require(msg.value >= 0.006 ether, "Insufficient ETH");
        LibDiamond.enforceIsContractOwner();
        payable(LibDiamond.diamondStorage().factory).transfer(msg.value);
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }

    function diamondCutByProposal(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata)
        external
        payable
    {
        require(msg.value >= 0.006 ether, "Insufficient ETH");
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");
        payable(LibDiamond.diamondStorage().factory).transfer(msg.value);
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
