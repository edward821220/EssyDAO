// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage} from "../utils/AppStorage.sol";

contract BasicDaoInit {
    AppStorage internal s;

    function init(string calldata name, string calldata symbol) external {
        s.name = name;
        s.symbol = symbol;
    }
}
