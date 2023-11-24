// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/Test.sol";
import {BasicSetup} from "./helper/BasicSetup.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../contracts/upgradeInitializers/DaoInit.sol";
import {OwnershipFacet} from "../contracts/facets/optional/OwnershipFacet.sol";
import {OwnershipInit} from "../contracts/upgradeInitializers/OwnershipInit.sol";
import {AppStorage, FounderInfo, Proposal, Side, Status} from "../contracts/utils/AppStorage.sol";

contract DiamondCutTest is BasicSetup {
    function setUp() public override {
        super.setUp();
    }

    // function testExecuteProposal() public {
    //     vm.startPrank(founderA);
    //     address diamond = factory.createDAODiamond(
    //         "EasyDAO",
    //         foundersInfo,
    //         "Goverence Token",
    //         "GOV",
    //         address(diamondCutFacet),
    //         address(diamondLoupeFacet),
    //         address(daoFacet),
    //         address(daoInit)
    //     );
    //     DaoFacet dao = DaoFacet(diamond);
    //     IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

    //     bytes4[] memory ownershipCutSelectors = new bytes4[](2);
    //     ownershipCutSelectors[0] = ownershipFacet.transferOwnership.selector;
    //     ownershipCutSelectors[1] = ownershipFacet.owner.selector;
    //     cut[0] = IDiamondCut.FacetCut({
    //         facetAddress: address(ownershipFacet),
    //         action: IDiamondCut.FacetCutAction.Add,
    //         functionSelectors: ownershipCutSelectors
    //     });

    //     uint256 proposalId = dao.createProposal(
    //         abi.encodeWithSelector(
    //             diamondCutFacet.diamondCutByProposal.selector,
    //             ++s.proposalCount,
    //             cut,
    //             address(ownershipInit),
    //             abi.encodeWithSignature("init(address)", founderB)
    //         )
    //     );
    //     dao.vote(proposalId, Side.Yes);
    //     assertEq(dao.checkIsVoted(proposalId), true);
    //     vm.stopPrank();

    //     vm.startPrank(founderB);
    //     dao.vote(proposalId, Side.Yes);
    //     assertEq(dao.checkIsVoted(proposalId), true);
    //     assertEq(uint256(dao.checkProposal(proposalId).status), 1);
    //     dao.executeProposal(proposalId);
    //     OwnershipFacet upgradedDao = OwnershipFacet(diamond);
    //     assertEq(upgradedDao.owner(), founderB);
    //     vm.stopPrank();
    // }
}
