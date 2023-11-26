// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../utils/LibDiamond.sol";

contract OwnershipInit {
    function init(address newOwner) external payable {
        LibDiamond.setContractOwner(newOwner);
    }
}
