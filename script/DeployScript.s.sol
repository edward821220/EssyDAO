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

contract DeployScript is Script {
    function run() public {
        bytes32 salt_ = keccak256(abi.encodePacked(vm.envUint("ADDRESS_LOCAL")));
        vm.startBroadcast(vm.envUint("PRIVATE_KEY_LOCAL"));
        new DiamondFactory{salt: salt_}();
        new DiamondCutFacet{salt: salt_}();
        new DiamondLoupeFacet{salt: salt_}();
        new DaoFacet{salt: salt_}();
        new DaoInit{salt: salt_}();
        new OwnershipFacet{salt: salt_}();
        new OwnershipInit{salt: salt_}();
        new DividendFacet{salt: salt_}();
        new DividendInit{salt: salt_}();
        new VaultFacet{salt: salt_}();
        new VaultInit{salt: salt_}();
        vm.stopBroadcast();
    }
}
