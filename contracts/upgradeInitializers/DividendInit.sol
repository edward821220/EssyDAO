// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage} from "../utils/AppStorage.sol";

contract DividendInit {
    AppStorage s;

    function init(uint256 duration, uint256 annualRate) external payable {
        s.dividendInfo.startTime = block.timestamp;
        s.dividendInfo.snapshopId = s.currentSnapshotId;
        s.dividendInfo.duration = duration;
        s.dividendInfo.annualRate = annualRate;
    }
}
