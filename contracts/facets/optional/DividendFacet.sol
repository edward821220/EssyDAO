// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MintFunctions} from "../../utils/MintFunctions.sol";
import {DaoFacet} from "../DaoFacet.sol";

contract DividendFacet is MintFunctions {
    function withdrawDividend() public returns (uint256 dividend) {
        dividend = calculateDividend();
        s.tokenReleased[msg.sender] += dividend;
        _mint(msg.sender, dividend);
    }

    function calculateDividend() public view returns (uint256) {
        DaoFacet dao = DaoFacet(s.diamond);
        uint256 snapshotId = s.dividendInfo.snapshopId;
        uint256 startTime = getStartTime();
        uint256 duration = getDuration();
        uint256 annualRate = getAnnualRate();
        uint256 timestamp = block.timestamp;

        uint256 initialBalance = dao.balanceOfAt(msg.sender, snapshotId);
        require(dao.balanceOf(msg.sender) >= initialBalance, "You should hold your initial balance");

        uint256 totalDividend = annualRate * (duration / 86400) * initialBalance / 100;
        uint256 releasedDividend = s.tokenReleased[msg.sender];

        if (timestamp < startTime) {
            return 0;
        } else if (timestamp - duration > startTime) {
            return totalDividend - releasedDividend;
        } else {
            return (totalDividend * (timestamp - startTime) / duration) - releasedDividend;
        }
    }

    function getStartTime() public view returns (uint256) {
        return s.dividendInfo.startTime;
    }

    function getDuration() public view returns (uint256) {
        return s.dividendInfo.duration;
    }

    function getAnnualRate() public view returns (uint256) {
        return s.dividendInfo.annualRate;
    }
}
