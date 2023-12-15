// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test} from "forge-std/Test.sol";
import {DiamondFactory} from "../../contracts/DiamondFactory.sol";
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "../../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../../contracts/upgradeInitializers/DaoInit.sol";
import {OwnershipFacet} from "../../contracts/facets/optional/OwnershipFacet.sol";
import {OwnershipInit} from "../../contracts/upgradeInitializers/OwnershipInit.sol";
import {DividendFacet} from "../../contracts/facets/optional/DividendFacet.sol";
import {DividendInit} from "../../contracts/upgradeInitializers/DividendInit.sol";
import {VaultFacet} from "../../contracts/facets/optional/VaultFacet.sol";
import {VaultInit} from "../../contracts/upgradeInitializers/VaultInit.sol";
import {AppStorage, FounderInfo} from "../../contracts/utils/AppStorage.sol";

contract SetUp is Test {
    AppStorage internal s;
    DiamondFactory internal factory;
    DiamondCutFacet internal diamondCutFacet;
    DiamondLoupeFacet internal diamondLoupeFacet;
    DaoFacet internal daoFacet;
    DaoInit internal daoInit;
    OwnershipFacet internal ownershipFacet;
    OwnershipInit internal ownershipInit;
    DividendFacet internal dividendFacet;
    DividendInit internal dividendInit;
    VaultFacet internal vaultFacet;
    VaultInit internal vaultInit;
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
        dividendFacet = new DividendFacet();
        dividendInit = new DividendInit();
        vaultFacet = new VaultFacet();
        vaultInit = new VaultInit();
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
        // Use block number as ERC20 snapshot id, so we should go next block.
        vm.roll(block.number + 1);
    }
}
