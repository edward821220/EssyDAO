// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../contracts/upgradeInitializers/DaoInit.sol";
import {OwnershipFacet} from "../contracts/facets/OwnershipFacet.sol";
import {OwnershipInit} from "../contracts/upgradeInitializers/OwnershipInit.sol";
import {AppStorage, FounderInfo, Proposal, Side, Status} from "../contracts/utils/AppStorage.sol";

contract DaoTest is Test {
    AppStorage internal s;
    DiamondFactory public factory;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    DaoFacet public daoFacet;
    DaoInit public daoInit;
    OwnershipFacet public ownershipFacet;
    OwnershipInit public ownershipInit;
    FounderInfo[] foundersInfo;

    address admin = makeAddr("Admin");
    address founder1 = makeAddr("Founder1");
    address founder2 = makeAddr("Founder2");
    address founder3 = makeAddr("Founder3");

    function setUp() public {
        vm.startPrank(admin);
        factory = new DiamondFactory(admin);
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        daoFacet = new DaoFacet();
        daoInit = new DaoInit();
        ownershipFacet = new OwnershipFacet();
        ownershipInit = new OwnershipInit();
        vm.stopPrank();

        foundersInfo.push(FounderInfo(founder1, 500 ether));
        foundersInfo.push(FounderInfo(founder2, 200 ether));
        foundersInfo.push(FounderInfo(founder3, 300 ether));
    }

    function testCreateDAO() public {
        vm.startPrank(founder1);
        address diamond = factory.createDAODiamond(
            "EasyDAO",
            foundersInfo,
            "Goverence Token",
            "GOV",
            address(diamondCutFacet),
            address(diamondLoupeFacet),
            address(daoFacet),
            address(daoInit)
        );
        DaoFacet dao = DaoFacet(diamond);
        assertEq(dao.name(), "Goverence Token");
        assertEq(dao.symbol(), "GOV");
        assertEq(dao.totalSupply(), 1000 ether);
        assertEq(dao.balanceOf(founder1), 500 ether);
        assertEq(dao.balanceOf(founder2), 200 ether);
        assertEq(dao.balanceOf(founder3), 300 ether);
        vm.stopPrank();
    }

    function testProposal() public {
        vm.startPrank(founder1);
        address diamond = factory.createDAODiamond(
            "EasyDAO",
            foundersInfo,
            "Goverence Token",
            "GOV",
            address(diamondCutFacet),
            address(diamondLoupeFacet),
            address(daoFacet),
            address(daoInit)
        );
        DaoFacet dao = DaoFacet(diamond);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory ownershipCutSelectors = new bytes4[](2);
        ownershipCutSelectors[0] = ownershipFacet.transferOwnership.selector;
        ownershipCutSelectors[1] = ownershipFacet.owner.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipCutSelectors
        });

        uint256 proposalId = dao.createProposal(
            abi.encodeWithSelector(
                diamondCutFacet.diamondCutByProposal.selector,
                ++s.proposalCount,
                cut,
                address(ownershipInit),
                abi.encodeWithSignature("init(address)", founder2)
            )
        );
        dao.vote(proposalId, Side.Yes);
        assertEq(dao.checkIsVoted(proposalId), true);
        vm.stopPrank();

        vm.startPrank(founder2);
        dao.vote(proposalId, Side.Yes);
        assertEq(dao.checkIsVoted(proposalId), true);
        assertEq(uint256(dao.checkProposal(proposalId).status), 1);
        dao.executeProposal(proposalId);
        OwnershipFacet upgradedDao = OwnershipFacet(diamond);
        assertEq(upgradedDao.owner(), founder2);
        vm.stopPrank();
    }
}
