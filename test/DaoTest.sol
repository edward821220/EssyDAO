// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../contracts/upgradeInitializers/DaoInit.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";
import {FounderInfo} from "../contracts/utils/AppStorage.sol";

contract DaoTest is Test {
    DiamondFactory public factory;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    DaoFacet public daoFacet;
    DaoInit public daoInit;
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
}
