// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RewardToken} from "./RewardToken.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title StakingContract
 * @author Ryan
 * @notice  contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours.
 * The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it.
 */
contract StakingContract is IERC721Receiver, Initializable, Ownable2Step {
    /**
     * @dev data structure for one staking action
     */
    struct Deposit {
        address staker;
        uint256 startTime;
    }

    uint256 private constant REWARD_DELAY = 1 days;
    uint256 private constant REWARD_AMT = 10;
    mapping(uint256 tokenId => Deposit) private deposits;
    address private immutable nftAddress;

    //reward token address will be initalized in initializer, because token address is not known when deploying (cycling dependency)
    address private tokenAddress;

    event Staked(address indexed staker, uint256 indexed tokenId, uint256 timestamp);
    event WithdrawnNFT(address indexed staker, uint256 indexed tokenId);
    event ColletedRewards(address indexed staker, uint256 indexed tokenId, uint256 rewardAmount);

    constructor(address _nftAddress) Ownable(msg.sender) {
        require(_nftAddress != address(0), "Zero address");
        nftAddress = _nftAddress;
    }

    /**
     * token contract needs staking contract address in constructor, so token contract address is not known when deploying staking contract address.
     * @param _tokenAddress reward token address
     */
    function initialize(address _tokenAddress) external onlyOwner initializer {
        require(_tokenAddress != address(0), "Zero address");
        tokenAddress = _tokenAddress;
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata)
        external
        override
        returns (bytes4)
    {
        require(msg.sender == address(nftAddress), "illeage call");
        deposits[tokenId] = Deposit(from, block.timestamp);
        emit Staked(from, tokenId, block.timestamp);

        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * Collect rewards for one token Id
     * @param tokenId NFT id to collect rewards
     */
    function collect(uint256 tokenId) external {
        _collect(tokenId);
    }

    /**
     * Collect rewards for a list of Ids, to save gas
     * @param tokenIds NFT id list
     */
    function bulkCollect(uint256[] calldata tokenIds) external {
        //tokenIds is calldata, no need to cache length
        for (uint256 i = 0; i < tokenIds.length;) {
            _collect(tokenIds[i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * Collect rewards and withdraw NFT from Staking
     * @param tokenId NFT id to withdraw
     */
    function withdrawNFT(uint256 tokenId) external {
        _collect(tokenId);

        Deposit memory deposit = deposits[tokenId];
        require(deposit.staker == msg.sender, "Must be owner of NFT");

        delete deposits[tokenId];
        emit WithdrawnNFT(msg.sender, tokenId);
        ERC721(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function _collect(uint256 tokenId) internal {
        Deposit memory deposit = deposits[tokenId];
        require(deposit.staker == msg.sender, "Must be owner of NFT");

        if (deposit.startTime + REWARD_DELAY > block.timestamp) {
            return;
        }

        uint256 oldStartTime = deposit.startTime;

        // intended divide before multiply, to around rewarded periods to integer
        uint256 rewardPeriods = (block.timestamp - oldStartTime) / 1 days;
        deposits[tokenId].startTime = oldStartTime + rewardPeriods * 1 days;

        emit ColletedRewards(msg.sender, tokenId, REWARD_AMT * rewardPeriods);
        RewardToken(tokenAddress).mintStakingRewards(msg.sender, REWARD_AMT * rewardPeriods);
    }

    /**
     * view function to get current rewards that can be collected
     * @param tokenId NFT id to collect
     */
    function calcRewards(uint256 tokenId) public view returns (uint256) {
        Deposit memory deposit = deposits[tokenId];
        uint256 oldStartTime = deposit.startTime;
        uint256 rewardPeriods = (block.timestamp - oldStartTime) / 1 days;

        return REWARD_AMT * rewardPeriods;
    }
}
