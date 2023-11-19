// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC173} from "./interfaces/IERC173.sol";
import {LibDiamond} from "./utils/LibDiamond.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "./facets/DiamondCutFacet.sol";
import {IDiamondLoupe} from "./interfaces/IDiamondLoupe.sol";
import {DiamondLoupeFacet} from "./facets/DiamondLoupeFacet.sol";
import {BasicDaoFacet} from "./facets/BasicDaoFacet.sol";
import {BasicDaoInit} from "./upgradeInitializers/BaicDaoInit.sol";

contract Diamond {
    constructor(
        address _contractOwner,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _diamondCutFacet,
        address _diamondLoupeFacet,
        address _basicDaoFacet,
        address _basicDaoInit
    ) payable {
        LibDiamond.setContractOwner(_contractOwner);

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // DiamondCutFacet
        bytes4[] memory diamondCutSelectors = new bytes4[](1);
        diamondCutSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: diamondCutSelectors
        });

        // DiamondLoupeFacet
        bytes4[] memory diamondLoupeSelectors = new bytes4[](4);
        diamondLoupeSelectors[0] = IDiamondLoupe.facets.selector;
        diamondLoupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        diamondLoupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        diamondLoupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        cut[1] = IDiamondCut.FacetCut({
            facetAddress: _diamondLoupeFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: diamondLoupeSelectors
        });

        // BasicDaoFacet
        bytes4[] memory basicDaoSelectors = new bytes4[](11);
        basicDaoSelectors[0] = BasicDaoFacet.createProposal.selector;
        basicDaoSelectors[1] = BasicDaoFacet.vote.selector;
        basicDaoSelectors[2] = BasicDaoFacet.name.selector;
        basicDaoSelectors[3] = BasicDaoFacet.symbol.selector;
        basicDaoSelectors[4] = BasicDaoFacet.decimals.selector;
        basicDaoSelectors[5] = BasicDaoFacet.totalSupply.selector;
        basicDaoSelectors[6] = BasicDaoFacet.balanceOf.selector;
        basicDaoSelectors[7] = BasicDaoFacet.allowance.selector;
        basicDaoSelectors[8] = BasicDaoFacet.transfer.selector;
        basicDaoSelectors[9] = BasicDaoFacet.approve.selector;
        basicDaoSelectors[10] = BasicDaoFacet.transferFrom.selector;

        cut[2] = IDiamondCut.FacetCut({
            facetAddress: _basicDaoFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: basicDaoSelectors
        });

        LibDiamond.diamondCut(
            cut, _basicDaoInit, abi.encodeWithSignature("init(string,string)", _tokenName, _tokenSymbol)
        );

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    }

    receive() external payable {}

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
