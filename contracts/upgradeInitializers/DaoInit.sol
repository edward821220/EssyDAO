// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage, FounderInfo} from "../utils/AppStorage.sol";

contract DaoInit {
    AppStorage internal s;

    function init(string calldata name, string calldata symbol, FounderInfo[] memory foundersInfo) external {
        s.name = name;
        s.symbol = symbol;
        for (uint256 i = 0; i < foundersInfo.length; ++i) {
            address founder = foundersInfo[i].founder;
            uint256 shares = foundersInfo[i].shares;
            s.totalSupply += shares;
            s.balances[founder] = shares;
        }
    }
}
