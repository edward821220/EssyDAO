// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SetUp} from "./helper/SetUp.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {DaoFacet} from "../contracts/facets/DaoFacet.sol";
import {DividendFacet} from "../contracts/facets/optional/DividendFacet.sol";
import {Side} from "../contracts/utils/AppStorage.sol";

contract DividendTest is SetUp {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public override {
        super.setUp();
    }

    function testWithdrawDividend() public {
        address daoDiamond = _createDAO();
        DaoFacet dao = DaoFacet(daoDiamond);

        vm.startPrank(founderA);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory dividendCutSelectors = new bytes4[](8);
        dividendCutSelectors[0] = dividendFacet.withdrawDividend.selector;
        dividendCutSelectors[1] = dividendFacet.calculateDividend.selector;
        dividendCutSelectors[2] = dividendFacet.getStartTime.selector;
        dividendCutSelectors[3] = dividendFacet.getDuration.selector;
        dividendCutSelectors[4] = dividendFacet.getAnnualRate.selector;
        dividendCutSelectors[5] = dividendFacet.getInitialBalance.selector;
        dividendCutSelectors[6] = dividendFacet.getTotalDividend.selector;
        dividendCutSelectors[7] = dividendFacet.getReleasedDividend.selector;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(dividendFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: dividendCutSelectors
        });

        // Use previous block number as proposal snapshot id, so we should go next block.
        vm.roll(block.number + 1);

        uint256 proposalId = dao.createProposal(
            abi.encodeWithSelector(
                diamondCutFacet.diamondCutByProposal.selector,
                cut,
                address(dividendInit),
                abi.encodeWithSignature("init(uint256,uint256)", 26 weeks, 5)
            ),
            "Upgrade",
            "Test proposal"
        );
        dao.vote(proposalId, Side.Yes);
        vm.stopPrank();

        vm.startPrank(founderB);
        dao.vote(proposalId, Side.Yes);
        dao.executeProposal{value: 0.006 ether}(proposalId);
        DividendFacet upgradedDao = DividendFacet(daoDiamond);
        assertEq(upgradedDao.getDuration(), 26 weeks);
        assertEq(upgradedDao.getAnnualRate(), 5);

        uint256 totalDividend = upgradedDao.getTotalDividend();
        uint256 halfDurationdDividend = totalDividend / 2;

        vm.warp(block.timestamp + 13 weeks);
        assertEq(upgradedDao.calculateDividend(), halfDurationdDividend);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(founderB), halfDurationdDividend);
        upgradedDao.withdrawDividend();
        uint256 releasedDividend = upgradedDao.getReleasedDividend();

        assertEq(releasedDividend, halfDurationdDividend);
        assertEq(upgradedDao.calculateDividend(), 0);

        vm.expectRevert("No dividend to withdraw");
        upgradedDao.withdrawDividend();

        vm.warp(block.timestamp + 13 weeks);
        assertEq(upgradedDao.calculateDividend(), totalDividend - releasedDividend);
        vm.stopPrank();
    }
}
