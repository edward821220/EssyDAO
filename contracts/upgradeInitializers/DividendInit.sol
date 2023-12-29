// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage} from "../utils/AppStorage.sol";

contract DividendInit {
    AppStorage s;

    function init(uint256 duration, uint256 annualRate) external payable {
        s.dividendTimes += 1;
        s.dividendInfo.startTime = block.timestamp;
        s.dividendInfo.snapshopId = block.number - 1;
        s.dividendInfo.duration = duration;
        s.dividendInfo.annualRate = annualRate;
    }
}
