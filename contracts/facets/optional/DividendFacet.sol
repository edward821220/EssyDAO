// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MintFunctions} from "../../utils/MintFunctions.sol";
import {DaoFacet} from "../DaoFacet.sol";

contract DividendFacet is MintFunctions {
    function withdrawDividend() public returns (uint256 dividend) {
        dividend = calculateDividend();
        require(dividend > 0, "No dividend to withdraw");
        s.tokenReleased[msg.sender] += dividend;
        _mint(msg.sender, dividend);
    }

    function calculateDividend() public view returns (uint256) {
        uint256 initialBalance = getInitialBalance();
        require(s.balances[msg.sender] >= initialBalance, "You should hold your initial balance");

        uint256 startTime = getStartTime();
        uint256 duration = getDuration();
        uint256 timestamp = block.timestamp;
        uint256 totalDividend = getTotalDividend();
        uint256 releasedDividend = getReleasedDividend();

        if (timestamp < startTime) {
            return 0;
        } else if (timestamp > startTime + duration) {
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

    function getInitialBalance() public view returns (uint256) {
        DaoFacet dao = DaoFacet(s.diamond);
        return dao.balanceOfAt(msg.sender, s.dividendInfo.snapshopId);
    }

    function getTotalDividend() public view returns (uint256 totalDividend) {
        totalDividend = (getAnnualRate() * getDuration() * getInitialBalance()) / (100 * 52 weeks);
    }

    function getReleasedDividend() public view returns (uint256 releasedDividend) {
        releasedDividend = s.tokenReleased[msg.sender];
    }
}
