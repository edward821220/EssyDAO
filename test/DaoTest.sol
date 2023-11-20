// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../contracts/upgradeInitializers/DaoInit.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";

contract DaoTest is Test {
    DiamondFactory public factory;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    DaoFacet public daoFacet;
    DaoInit public daoInit;

    address admin = makeAddr("Admin");
    address founder = makeAddr("Founder");

    function setUp() public {
        vm.startPrank(admin);
        factory = new DiamondFactory(admin);
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        daoFacet = new DaoFacet();
        daoInit = new DaoInit();
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
            address(daoFacet),
            address(daoInit)
        );
        DaoFacet dao = DaoFacet(diamond);
        assertEq(dao.name(), "Goverence Token");
        assertEq(dao.symbol(), "GOV");
        vm.stopPrank();
    }
}
