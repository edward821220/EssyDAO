// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage} from "../utils/AppStorage.sol";
import {LibDiamond} from "../utils/LibDiamond.sol";

contract OwnershipInit {
    function init(address newOwner) external {
        LibDiamond.setContractOwner(newOwner);
    }
}
