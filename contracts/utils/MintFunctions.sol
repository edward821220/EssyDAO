// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
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
        uint256 currentId = _getCurrentSnapshotId();
        snapshots.ids.push(currentId);
        snapshots.values.push(currentValue);
    }

    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return block.number;
    }
}
