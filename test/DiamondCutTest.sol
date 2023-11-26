// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BasicSetup} from "./helper/BasicSetup.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {OwnershipFacet} from "../contracts/facets/optional/OwnershipFacet.sol";
import {Side, Status} from "../contracts/utils/AppStorage.sol";

contract DiamondCutTest is BasicSetup {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setUp() public override {
        super.setUp();
    }

    // Add ownership facet to test
    function testDiamondCutByProposal() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory ownershipCutSelectors = new bytes4[](2);
        ownershipCutSelectors[0] = ownershipFacet.owner.selector;
        ownershipCutSelectors[1] = ownershipFacet.transferOwnership.selector;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipCutSelectors
        });

        uint256 proposalId = dao.createProposal(
            abi.encodeWithSelector(
                diamondCutFacet.diamondCutByProposal.selector,
                cut,
                address(ownershipInit),
                abi.encodeWithSignature("init(address)", founderB)
            )
        );
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(address(0), founderB);
        dao.executeProposal{value: 0.006 ether}(proposalId);
        OwnershipFacet upgradedDao = OwnershipFacet(daoDiamond);
        vm.stopPrank();

        assertEq(address(factory).balance, 0.006 ether);
        assertEq(upgradedDao.owner(), founderB);
        assertEq(uint256(dao.checkProposal(proposalId).status), uint256(Status.Finished));
    }
}
