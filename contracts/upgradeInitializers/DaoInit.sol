// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage, FounderInfo} from "../utils/AppStorage.sol";

contract DaoInit {
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
            s.totalSupply += shares;
            s.balances[founder] = shares;
        }
    }
}
