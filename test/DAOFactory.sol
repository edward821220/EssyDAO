// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAOFactory} from "../src/DAOFactory.sol";

contract DAOFactoryTest is Test {
    DAOFactory public factory;

    function setUp() public {
        factory = new DAOFactory();
    }

    function test_create() public {}
}
