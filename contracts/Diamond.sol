// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC173} from "./interfaces/IERC173.sol";
import {LibDiamond} from "./utils/LibDiamond.sol";
import {FounderInfo} from "./utils/AppStorage.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "./facets/DiamondCutFacet.sol";
import {IDiamondLoupe} from "./interfaces/IDiamondLoupe.sol";
import {DiamondLoupeFacet} from "./facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "./facets/DaoFacet.sol";
import {DaoInit} from "./upgradeInitializers/DaoInit.sol";

contract Diamond {
    constructor(
        address contractOwner,
        FounderInfo[] memory foundersInfo,
        string memory tokenName,
        string memory tokenSymbol,
        address diamondCutFacet,
        address diamondLoupeFacet,
        address daoFacet,
        address daoInit
    ) payable {
        LibDiamond.setContractOwner(contractOwner);

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        {
            // DiamondCutFacet
            bytes4[] memory diamondCutSelectors = new bytes4[](2);
            diamondCutSelectors[0] = IDiamondCut.diamondCut.selector;
            diamondCutSelectors[1] = IDiamondCut.diamondCutByProposal.selector;
            cut[0] = IDiamondCut.FacetCut({
                facetAddress: diamondCutFacet,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: diamondCutSelectors
            });
        }

        {
            // DiamondLoupeFacet
            bytes4[] memory diamondLoupeSelectors = new bytes4[](4);
            diamondLoupeSelectors[0] = IDiamondLoupe.facets.selector;
            diamondLoupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
            diamondLoupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
            diamondLoupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

            cut[1] = IDiamondCut.FacetCut({
                facetAddress: diamondLoupeFacet,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: diamondLoupeSelectors
            });
        }

        {
            // DaoFacet
            bytes4[] memory daoSelectors = new bytes4[](14);
            daoSelectors[0] = DaoFacet.createProposal.selector;
            daoSelectors[1] = DaoFacet.vote.selector;
            daoSelectors[2] = DaoFacet.name.selector;
            daoSelectors[3] = DaoFacet.symbol.selector;
            daoSelectors[4] = DaoFacet.decimals.selector;
            daoSelectors[5] = DaoFacet.totalSupply.selector;
            daoSelectors[6] = DaoFacet.balanceOf.selector;
            daoSelectors[7] = DaoFacet.allowance.selector;
            daoSelectors[8] = DaoFacet.transfer.selector;
            daoSelectors[9] = DaoFacet.approve.selector;
            daoSelectors[10] = DaoFacet.transferFrom.selector;
            daoSelectors[11] = DaoFacet.checkIsVoted.selector;
            daoSelectors[12] = DaoFacet.checkProposal.selector;
            daoSelectors[13] = DaoFacet.executeProposal.selector;

            cut[2] = IDiamondCut.FacetCut({
                facetAddress: daoFacet,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: daoSelectors
            });

            LibDiamond.diamondCut(
                cut,
                daoInit,
                abi.encodeWithSignature(
                    "init(address,string,string,(address,uint256)[])",
                    address(this),
                    tokenName,
                    tokenSymbol,
                    foundersInfo
                )
            );
        }
        {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
            ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
            ds.supportedInterfaces[type(IERC165).interfaceId] = true;
            ds.supportedInterfaces[type(IERC173).interfaceId] = true;

            LibDiamond.setContractOwner(address(0));
        }
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
