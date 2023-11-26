// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage, Snapshots} from "../utils/AppStorage.sol";

contract MintFunctions {
    event Transfer(address indexed from, address indexed to, uint256 value);

    AppStorage internal s;

    function _mint(address to, uint256 value) internal {
        _updateTotalSupplySnapshot();
        s.totalSupply += value;

        _updateAccountSnapshot(to);
        unchecked {
            s.balances[to] += value;
        }

        emit Transfer(address(0), to, value);
    }

    function _updateAccountSnapshot(address account) internal {
        _updateSnapshot(s.accountBalanceSnapshots[account], s.balances[account]);
    }

    function _updateTotalSupplySnapshot() internal {
        _updateSnapshot(s.totalSupplySnapshots, s.totalSupply);
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) internal {
        uint256 currentId = s.currentSnapshotId;
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
        _snapshot();
    }

    function _lastSnapshotId(uint256[] storage ids) internal view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    function _snapshot() internal returns (uint256) {
        s.currentSnapshotId++;
        uint256 currentId = s.currentSnapshotId;
        return currentId;
    }
}
