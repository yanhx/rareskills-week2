// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingContract} from "../src/StakingContract.sol";

contract DeployStakingContract is Script {
    function run(address nftAddress) external returns (RewardToken, StakingContract) {
        vm.startBroadcast();

        StakingContract stakingContract = new StakingContract(nftAddress);
        RewardToken rewardToken = new RewardToken(address(stakingContract));

        stakingContract.initialize(address(rewardToken));

        vm.stopBroadcast();
        return (rewardToken, stakingContract);
    }
}
