// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../../contracts/DiamondFactory.sol";
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "../../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../../contracts/upgradeInitializers/DaoInit.sol";
import {OwnershipFacet} from "../../contracts/facets/optional/OwnershipFacet.sol";
import {OwnershipInit} from "../../contracts/upgradeInitializers/OwnershipInit.sol";
import {AppStorage, FounderInfo} from "../../contracts/utils/AppStorage.sol";

contract BasicSetup is Test {
    AppStorage internal s;
    DiamondFactory internal factory;
    DiamondCutFacet internal diamondCutFacet;
    DiamondLoupeFacet internal diamondLoupeFacet;
    DaoFacet internal daoFacet;
    DaoInit internal daoInit;
    OwnershipFacet internal ownershipFacet;
    OwnershipInit internal ownershipInit;
    FounderInfo[] internal foundersInfo;

    address admin = makeAddr("Admin");
    address founderA = makeAddr("FounderA");
    address founderB = makeAddr("FounderB");
    address founderC = makeAddr("FounderC");
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");

    function setUp() public virtual {
        vm.startPrank(admin);
        factory = new DiamondFactory(admin);
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        daoFacet = new DaoFacet();
        daoInit = new DaoInit();
        ownershipFacet = new OwnershipFacet();
        ownershipInit = new OwnershipInit();
        vm.stopPrank();

        foundersInfo.push(FounderInfo(founderA, 500 ether));
        foundersInfo.push(FounderInfo(founderB, 200 ether));
        foundersInfo.push(FounderInfo(founderC, 300 ether));

        deal(founderA, 100 ether);
        deal(founderB, 100 ether);
        deal(founderC, 100 ether);
    }

    function _createDAO() internal returns (address daoDiamond) {
        vm.startPrank(founderA);
        daoDiamond = factory.createDAODiamond(
            "EasyDAO",
            foundersInfo,
            "Goverence Token",
            "GOV",
            address(diamondCutFacet),
            address(diamondLoupeFacet),
            address(daoFacet),
            address(daoInit)
        );
        vm.stopPrank();
    }
}
