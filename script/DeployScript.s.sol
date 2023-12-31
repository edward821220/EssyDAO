// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";
import {DiamondCutFacet} from "../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/facets/DiamondLoupeFacet.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DaoInit} from "../contracts/upgradeInitializers/DaoInit.sol";
import {OwnershipFacet} from "../contracts/facets/optional/OwnershipFacet.sol";
import {OwnershipInit} from "../contracts/upgradeInitializers/OwnershipInit.sol";
import {DividendFacet} from "../contracts/facets/optional/DividendFacet.sol";
import {DividendInit} from "../contracts/upgradeInitializers/DividendInit.sol";
import {VaultFacet} from "../contracts/facets/optional/VaultFacet.sol";
import {VaultInit} from "../contracts/upgradeInitializers/VaultInit.sol";
import {Market} from "../contracts/Market.sol";

contract DeployScript is Script {
    function run() public {
        bytes32 salt_ = keccak256(abi.encodePacked(vm.envUint("ADDRESS_LOCAL"), "EasyDAO contracts"));

        vm.startBroadcast(vm.envUint("PRIVATE_KEY_LOCAL"));
        DiamondFactory diamondFactory = new DiamondFactory{salt: salt_}();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet{salt: salt_}();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet{salt: salt_}();
        DaoFacet daoFacet = new DaoFacet{salt: salt_}();
        DaoInit daoInit = new DaoInit{salt: salt_}();
        OwnershipFacet ownershipFacet = new OwnershipFacet{salt: salt_}();
        OwnershipInit ownershipInit = new OwnershipInit{salt: salt_}();
        DividendFacet dividendFacet = new DividendFacet{salt: salt_}();
        DividendInit dividendInit = new DividendInit{salt: salt_}();
        VaultFacet vaultFacet = new VaultFacet{salt: salt_}();
        VaultInit vaultInit = new VaultInit{salt: salt_}();
        Market market = new Market{salt: salt_}();

        console2.log("DiamondFactory", address(diamondFactory));
        console2.log("DiamondCutFacet", address(diamondCutFacet));
        console2.log("DiamondLoupeFacet", address(diamondLoupeFacet));
        console2.log("DaoFacet", address(daoFacet));
        console2.log("DaoInit", address(daoInit));
        console2.log("OwnershipFacet", address(ownershipFacet));
        console2.log("OwnershipInit", address(ownershipInit));
        console2.log("DividendFacet", address(dividendFacet));
        console2.log("DividendInit", address(dividendInit));
        console2.log("VaultFacet", address(vaultFacet));
        console2.log("VaultInit", address(vaultInit));
        console2.log("Market", address(market));
        vm.stopBroadcast();
    }
}
