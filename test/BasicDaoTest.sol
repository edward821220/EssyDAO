// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {BasicDaoFacet} from "../contracts/facets/BasicDaoFacet.sol";
import {BasicDaoInit} from "../contracts/upgradeInitializers/BaicDaoInit.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";

contract BasicDaoTest is Test {
    DiamondFactory public factory;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    BasicDaoFacet public basicDaoFacet;
    BasicDaoInit public basicDaoInit;

    address admin = makeAddr("Admin");
    address founder = makeAddr("Founder");

    function setUp() public {
        vm.startPrank(admin);
        factory = new DiamondFactory(admin);
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        basicDaoFacet = new BasicDaoFacet();
        basicDaoInit = new BasicDaoInit();
        vm.stopPrank();
    }

    function testCreateDAO() public {
        vm.startPrank(founder);
        address diamond = factory.createDAODiamond(
            "EasyDAO",
            "Goverence Token",
            "GOV",
            address(diamondCutFacet),
            address(diamondLoupeFacet),
            address(basicDaoFacet),
            address(basicDaoInit)
        );
        BasicDaoFacet basicDao = BasicDaoFacet(diamond);
        assertEq(basicDao.name(), "Goverence Token");
        assertEq(basicDao.symbol(), "GOV");
        vm.stopPrank();
    }
}
