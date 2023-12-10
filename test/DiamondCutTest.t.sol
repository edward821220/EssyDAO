// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SetUp} from "./helper/SetUp.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {OwnershipFacet} from "../contracts/facets/optional/OwnershipFacet.sol";
import {Side, Status} from "../contracts/utils/AppStorage.sol";

contract DiamondCutTest is SetUp {
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

        vm.startPrank(founderB);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(founderB, founderC);
        upgradedDao.transferOwnership(founderC);
        assertEq(upgradedDao.owner(), founderC);
        vm.stopPrank();
    }

    // Remove ownership facet to test
    function testDiamondCutByOwner() public {
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
                abi.encodeWithSignature("init(address)", founderC)
            )
        );
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(address(0), founderC);
        dao.executeProposal{value: 0.006 ether}(proposalId);
        IDiamondCut upgradedDao = IDiamondCut(daoDiamond);
        vm.stopPrank();

        vm.startPrank(founderC);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: ownershipCutSelectors
        });

        upgradedDao.diamondCut{value: 0.006 ether}(
            cut, address(ownershipInit), abi.encodeWithSignature("init(address)", address(0))
        );

        // After removing ownership facet, the previous owner will lose ownership
        vm.expectRevert("LibDiamond: Must be contract owner");
        upgradedDao.diamondCut{value: 0.006 ether}(
            cut, address(ownershipInit), abi.encodeWithSignature("init(address)", address(0))
        );
        // And the new DAO will not be have any ownership method
        OwnershipFacet upgradedV2Dao = OwnershipFacet(daoDiamond);
        vm.expectRevert("Diamond: Function does not exist");
        upgradedV2Dao.transferOwnership(founderA);

        vm.stopPrank();
    }
}
