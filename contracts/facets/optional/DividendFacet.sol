// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage, Snapshots} from "../../utils/AppStorage.sol";
import {DaoFacet} from "../DaoFacet.sol";

contract DividendFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);

    AppStorage internal s;

    function withdrawDividend() public returns (uint256 dividend) {
        dividend = calculateDividend();
        s.tokenReleased[msg.sender] += dividend;
        _mint(msg.sender, dividend);
    }

    function calculateDividend() public view returns (uint256) {
        DaoFacet dao = DaoFacet(s.diamond);
        uint256 snapshotId = s.dividendInfo.snapshopId;
        uint256 startTime = getStartTime();
        uint256 duration = getDuration();
        uint256 annualRate = getAnnualRate();
        uint256 timestamp = block.timestamp;

        uint256 initialBalance = dao.balanceOfAt(msg.sender, snapshotId);
        require(dao.balanceOf(msg.sender) >= initialBalance, "You should hold your initial balance");

        uint256 totalDividend = annualRate * (duration / 86400) * initialBalance / 100;
        uint256 releasedDividend = s.tokenReleased[msg.sender];

        if (timestamp < startTime) {
            return 0;
        } else if (timestamp - duration > startTime) {
            return totalDividend - releasedDividend;
        } else {
            return (totalDividend * (timestamp - startTime) / duration) - releasedDividend;
        }
    }

    function getStartTime() public view returns (uint256) {
        return s.dividendInfo.startTime;
    }

    function getDuration() public view returns (uint256) {
        return s.dividendInfo.duration;
    }

    function getAnnualRate() public view returns (uint256) {
        return s.dividendInfo.annualRate;
    }

    function _mint(address to, uint256 value) internal {
        _updateTotalSupplySnapshot();
        s.totalSupply += value;

        _updateAccountSnapshot(to);
        unchecked {
            s.balances[to] += value;
        }

        emit Transfer(address(0), to, value);
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(s.accountBalanceSnapshots[account], s.balances[account]);
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(s.totalSupplySnapshots, s.totalSupply);
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = s.currentSnapshotId;
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
        _snapshot();
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    function _snapshot() private returns (uint256) {
        s.currentSnapshotId++;
        uint256 currentId = s.currentSnapshotId;
        return currentId;
    }
}
