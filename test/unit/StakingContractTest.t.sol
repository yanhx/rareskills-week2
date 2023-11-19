// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyNFT} from "../../script/DeployMyNFT.s.sol";
import {DeployStakingContract} from "../../script/DeployStakingContract.s.sol";
import {MyNFT} from "../../src/MyNFT.sol";
import {RewardToken} from "../../src/RewardToken.sol";
import {StakingContract} from "../../src/StakingContract.sol";

contract StakingContractTest is Test {
    MyNFT myNFT;
    RewardToken rewardToken;
    StakingContract stakingContract;

    address USER = address(0x1);
    address USER2 = address(0x200);

    uint256 private constant REWARD_DELAY = 1 days;
    uint256 private constant REWARD_AMT = 10;

    function setUp() public {
        DeployMyNFT deployMyNFT = new DeployMyNFT();
        myNFT = deployMyNFT.run();
        DeployStakingContract deployer = new DeployStakingContract();
        (rewardToken, stakingContract) = deployer.run(address(myNFT));
    }

    modifier mintAndStake() {
        // mint NFT
        vm.deal(USER, 0.1 ether);
        vm.prank(USER);
        myNFT.mint{value: 0.1 ether}();

        //stake NFT
        vm.prank(USER);
        myNFT.safeTransferFrom(USER, address(stakingContract), 0);
        _;
    }

    function testSimpleStake() public mintAndStake {
        assertEq(myNFT.balanceOf(USER), 0);
    }

    function testWithdraw() public mintAndStake {
        vm.prank(USER);
        stakingContract.withdrawNFT(0);
        assertEq(myNFT.balanceOf(USER), 1);
    }

    function testWithdrawNotOwner() public mintAndStake {
        vm.prank(USER2);
        vm.expectRevert("Must be owner of NFT");
        stakingContract.withdrawNFT(0);
    }

    function testWithdrawPlusRewards() public mintAndStake {
        vm.warp(block.timestamp + REWARD_DELAY + 1);
        vm.roll(block.number + 1);

        // withdraw NFT
        vm.prank(USER);
        stakingContract.withdrawNFT(0);
        assertEq(myNFT.balanceOf(USER), 1);
        assertEq(rewardToken.balanceOf(USER), REWARD_AMT * 10 ** 18);
    }

    function testCollect() public mintAndStake {
        vm.warp(block.timestamp + REWARD_DELAY + 1);
        vm.roll(block.number + 1);

        vm.prank(USER);
        stakingContract.collect(0);
        assertEq(myNFT.balanceOf(USER), 0);
        assertEq(rewardToken.balanceOf(USER), REWARD_AMT * 10 ** 18);
    }

    function testCollectTokensFailNotOwner() public mintAndStake {
        vm.warp(block.timestamp + REWARD_DELAY + 1);
        vm.roll(block.number + 1);

        vm.prank(USER2);
        vm.expectRevert("Must be owner of NFT");
        stakingContract.collect(0);
    }

    function testCollectTokensFailMustWait() public mintAndStake {
        vm.warp(block.timestamp + REWARD_DELAY - 1);
        vm.roll(block.number + 1);

        vm.prank(USER);
        stakingContract.collect(0);
        assertEq(rewardToken.balanceOf(USER), 0);
    }

    function testBulkCollectTokens() public mintAndStake {
        // mint NFT
        vm.deal(USER, 0.1 ether);
        vm.prank(USER);
        myNFT.mint{value: 0.1 ether}();

        //stake NFT
        vm.prank(USER);
        myNFT.safeTransferFrom(USER, address(stakingContract), 1);

        assertEq(myNFT.balanceOf(address(stakingContract)), 2);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;

        vm.warp(block.timestamp + REWARD_DELAY + 1);
        vm.roll(block.number + 1);
        vm.prank(USER);
        stakingContract.bulkCollect(tokenIds);
        assertEq(rewardToken.balanceOf(USER), REWARD_AMT * 2 * 10 ** 18);
    }

    function testBulkCollectTokensNotOwner() public mintAndStake {
        // mint NFT
        vm.deal(USER, 0.1 ether);
        vm.prank(USER);
        myNFT.mint{value: 0.1 ether}();

        //stake NFT
        vm.prank(USER);
        myNFT.safeTransferFrom(USER, address(stakingContract), 1);

        assertEq(myNFT.balanceOf(address(stakingContract)), 2);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;

        vm.warp(block.timestamp + REWARD_DELAY + 1);
        vm.roll(block.number + 1);
        vm.prank(USER2);
        vm.expectRevert("Must be owner of NFT");
        stakingContract.bulkCollect(tokenIds);
        assertEq(rewardToken.balanceOf(USER2), 0);
    }
}
