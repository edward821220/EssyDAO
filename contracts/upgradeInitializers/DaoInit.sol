// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage, FounderInfo, Snapshots} from "../utils/AppStorage.sol";
import {DaoFacet} from "../facets/DaoFacet.sol";

contract DaoInit {
    event Transfer(address indexed from, address indexed to, uint256 value);

    AppStorage internal s;

    function init(
        address diamond,
        string calldata daoName,
        string calldata tokenName,
        string calldata tokenSymbol,
        FounderInfo[] calldata foundersInfo
    ) external {
        s.daoName = daoName;
        s.tokenName = tokenName;
        s.symbol = tokenSymbol;
        s.diamond = diamond;
        for (uint256 i = 0; i < foundersInfo.length; ++i) {
            address founder = foundersInfo[i].founder;
            uint256 shares = foundersInfo[i].shares;
            _mint(founder, shares);
        }
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
