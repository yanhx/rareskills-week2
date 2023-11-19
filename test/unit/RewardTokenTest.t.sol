// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyNFT} from "../../script/DeployMyNFT.s.sol";
import {DeployStakingContract} from "../../script/DeployStakingContract.s.sol";
import {MyNFT} from "../../src/MyNFT.sol";
import {RewardToken} from "../../src/RewardToken.sol";
import {StakingContract} from "../../src/StakingContract.sol";

contract RewardTokenTest is Test {
    MyNFT myNFT;
    RewardToken rewardToken;
    StakingContract stakingContract;

    address USER = makeAddr("user");

    function setUp() public {
        DeployMyNFT deployMyNFT = new DeployMyNFT();
        myNFT = deployMyNFT.run();
        DeployStakingContract deployer = new DeployStakingContract();
        (rewardToken, stakingContract) = deployer.run(address(myNFT));
    }

    function testSetStakingAddress() public {
        assertEq(rewardToken.getStakingContract(), address(stakingContract));
    }

    function testMintStakingRewardsFail() public {
        vm.prank(USER);
        vm.expectRevert("invaild staking contract");
        rewardToken.mintStakingRewards(address(0), 0);
    }
}
