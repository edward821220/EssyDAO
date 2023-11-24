// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {BasicSetup} from "./helper/BasicSetup.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";

contract FactoryTest is BasicSetup {
    error OwnableUnauthorizedAccount(address account);

    function setUp() public override {
        super.setUp();
    }

    function testCreateDAO() public {
        DaoFacet dao = DaoFacet(_createDAO());

        assertEq(dao.name(), "Goverence Token");
        assertEq(dao.symbol(), "GOV");
        assertEq(dao.totalSupply(), 1000 ether);
        assertEq(dao.balanceOf(founder1), 500 ether);
        assertEq(dao.balanceOf(founder2), 200 ether);
        assertEq(dao.balanceOf(founder3), 300 ether);
        assertEq(factory.getDAO(0), address(dao));
    }

    function testWithdraw() public {
        deal(address(factory), 100 ether);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, alice));
        factory.withdraw();

        vm.prank(admin);
        factory.withdraw();
        assertEq(admin.balance, 100 ether);
    }
}
