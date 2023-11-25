// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {AppStorage, Side, Proposal, Status, Receiver} from "../utils/AppStorage.sol";

contract DaoFacet is IERC20, IERC20Metadata, IERC20Errors {
    AppStorage internal s;

    uint256 constant CREATE_PROPOSAL_MIN_SHARES = 100e18;
    uint256 constant VOTING_PERIOD = 7 days;

    function createProposal(bytes calldata data_) external returns (uint256 proposalId) {
        require(balanceOf(msg.sender) >= CREATE_PROPOSAL_MIN_SHARES, "No enough shares to create proposal");
        proposalId = s.proposals.length + 1;
        s.proposals.push(
            Proposal({
                id: proposalId,
                author: msg.sender,
                createdAt: block.timestamp,
                votesYes: 0,
                votesNo: 0,
                data: data_,
                status: Status.Pending
            })
        );
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = s.proposals[proposalId - 1];
        require(proposal.status == Status.Approved, "Proposal is not approved");
        require(proposal.data.length > 0, "No data to execute");
        (bool success,) = s.diamond.call(proposal.data);
        require(success, "Failed to execute");
        proposal.status = Status.Finished;
    }

    function vote(uint256 proposalId, Side side) external {
        require(balanceOf(msg.sender) > 0, "You are not the member of the DAO");
        require(s.isVoted[msg.sender][proposalId] == false, "Already voted");
        require(block.timestamp - s.proposals[proposalId - 1].createdAt < VOTING_PERIOD, "Voting period is over");

        s.isVoted[msg.sender][proposalId] = true;
        Proposal storage proposal = s.proposals[proposalId - 1];
        if (side == Side.Yes) {
            proposal.votesYes += balanceOf(msg.sender);
            if (proposal.votesYes * 100 / totalSupply() > 50) {
                proposal.status = Status.Approved;
            }
        } else {
            proposal.votesNo += balanceOf(msg.sender);
            if (proposal.votesNo * 100 / totalSupply() > 50) {
                proposal.status = Status.Rejected;
            }
        }
    }

    function checkIsVoted(uint256 proposalId) external view returns (bool) {
        return s.isVoted[msg.sender][proposalId];
    }

    function checkProposal(uint256 proposalId) external view returns (Proposal memory) {
        return s.proposals[proposalId - 1];
    }

    function getProposals() external view returns (Proposal[] memory) {
        return s.proposals;
    }

    function mintByProposal(Receiver[] calldata receivers) external {
        require(msg.sender == s.diamond, "Only executeProposal function can call this function");
        for (uint256 i = 0; i < receivers.length; ++i) {
            require(receivers[i].amount <= 8888 ether, "Amount must be less than 10000 ether");
            _mint(receivers[i].receiver, receivers[i].amount);
        }
    }

    function daoName() public view returns (string memory) {
        return s.daoName;
    }

    function name() public view returns (string memory) {
        return s.tokenName;
    }

    function symbol() public view returns (string memory) {
        return s.symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return s.totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return s.balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return s.allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            s.totalSupply += value;
        } else {
            uint256 fromBalance = s.balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                s.balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                s.totalSupply -= value;
            }
        } else {
            unchecked {
                s.balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        s.allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
