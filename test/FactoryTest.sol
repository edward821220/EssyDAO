// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {BasicSetup} from "./helper/BasicSetup.sol";
import {Diamond} from "../contracts/Diamond.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";

contract FactoryTest is BasicSetup {
    event DAOCreated(address indexed daoAddress, address indexed founder);

    error OwnableUnauthorizedAccount(address account);

    function setUp() public override {
        super.setUp();
    }

    function testCreateDAO() public {
        address calculatedAddress = _calculateAddress();

        vm.expectEmit(true, true, true, true);
        emit DAOCreated(calculatedAddress, founderA);
        DaoFacet dao = DaoFacet(_createDAO());

        assertEq(factory.owner(), admin);
        assertEq(factory.getDAO(0), address(dao));
        assertEq(dao.name(), "Goverence Token");
        assertEq(dao.symbol(), "GOV");
        assertEq(dao.totalSupply(), 1000 ether);
        assertEq(dao.balanceOf(founderA), 500 ether);
        assertEq(dao.balanceOf(founderB), 200 ether);
        assertEq(dao.balanceOf(founderC), 300 ether);
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

    function _calculateAddress() private view returns (address) {
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(Diamond).creationCode,
                abi.encode(
                    founderA,
                    foundersInfo,
                    "Goverence Token",
                    "GOV",
                    address(diamondCutFacet),
                    address(diamondLoupeFacet),
                    address(daoFacet),
                    address(daoInit)
                )
            )
        );

        bytes32 salt = keccak256(abi.encodePacked("EasyDAO", founderA));
        bytes32 calculatedAddressHash = keccak256(abi.encodePacked(bytes1(0xff), address(factory), salt, bytecodeHash));

        return address(uint160(uint256(calculatedAddressHash)));
    }
}
