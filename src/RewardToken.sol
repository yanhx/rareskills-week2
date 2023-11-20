// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract RewardToken is ERC20, Ownable2Step {
    address private immutable stakingContract;

    modifier OnlyStakingContract() {
        require(msg.sender == stakingContract, "invaild staking contract");
        _;
    }

    constructor(address _stakingContract) ERC20("RewardToken", "RT") Ownable(msg.sender) {
        require(_stakingContract != address(0), "Zero address");
        stakingContract = _stakingContract;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function mintStakingRewards(address account, uint256 amountWithoutDecimals) external OnlyStakingContract {
        _mint(account, amountWithoutDecimals * 10 ** decimals());
    }

    function getStakingContract() public view returns (address) {
        return stakingContract;
    }
}
