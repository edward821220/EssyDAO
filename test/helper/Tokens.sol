// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BearNFT is ERC721 {
    constructor() ERC721("BearNFT", "BNFT") {
        _safeMint(msg.sender, 88);
    }
}

contract BearToken is ERC20 {
    constructor() ERC20("BearToken", "BT") {
        _mint(msg.sender, 8888 ether);
    }
}
