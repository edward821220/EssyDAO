// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DiamondFactory} from "../contracts/DiamondFactory.sol";

contract DAOFactoryTest is Test {
    DiamondFactory public factory;
    address alice = makeAddr("Alice");

    function setUp() public {
        vm.startPrank(alice);
        factory = new DiamondFactory(alice);
    }

    function test_create() public {}
}
