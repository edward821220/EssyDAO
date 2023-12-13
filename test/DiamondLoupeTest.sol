// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SetUp} from "./helper/SetUp.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../contracts/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../contracts/interfaces/IERC173.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract DiamondCutTest is SetUp {
    DiamondLoupeFacet diamondLoupe;

    function setUp() public override {
        super.setUp();
        diamondLoupe = DiamondLoupeFacet(_createDAO());
    }

    function testFacets() public {
        assertEq(diamondLoupe.facets().length, 3);
    }

    function testFacetFunctionSelectors() public {
        assertEq(diamondLoupe.facetFunctionSelectors(address(diamondCutFacet)).length, 2);
        assertEq(diamondLoupe.facetFunctionSelectors(address(diamondLoupeFacet)).length, 5);
        assertEq(diamondLoupe.facetFunctionSelectors(address(daoFacet)).length, 20);
    }

    function testFacetAddresses() public {
        assertEq(diamondLoupe.facetAddresses().length, 3);
        assertEq(diamondLoupe.facetAddresses()[0], address(diamondCutFacet));
        assertEq(diamondLoupe.facetAddresses()[1], address(diamondLoupeFacet));
        assertEq(diamondLoupe.facetAddresses()[2], address(daoFacet));
    }

    function testFacetAddress() public {
        assertEq(diamondLoupe.facetAddress(diamondCutFacet.diamondCut.selector), address(diamondCutFacet));
        assertEq(diamondLoupe.facetAddress(diamondLoupeFacet.facets.selector), address(diamondLoupeFacet));
        assertEq(diamondLoupe.facetAddress(daoFacet.createProposal.selector), address(daoFacet));
    }

    function testSupportsInterface() public {
        assertEq(diamondLoupe.supportsInterface(type(IDiamondCut).interfaceId), true);
        assertEq(diamondLoupe.supportsInterface(type(IDiamondLoupe).interfaceId), true);
        assertEq(diamondLoupe.supportsInterface(type(IERC165).interfaceId), true);
        assertEq(diamondLoupe.supportsInterface(type(IERC173).interfaceId), true);
    }
}
