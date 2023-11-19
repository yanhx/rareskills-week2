// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RewardToken} from "./RewardToken.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract StakingContract is IERC721Receiver, Initializable, Ownable2Step {
    struct Deposit {
        address staker;
        uint256 startTime;
    }

    uint256 private constant REWARD_DELAY = 1 days;
    uint256 private constant REWARD_AMT = 10;
    mapping(uint256 => Deposit) private deposits;
    address private immutable nftAddress;
    address private tokenAddress;

    event Staked(address indexed staker, uint256 indexed tokenId, uint256 timestamp);
    event WithdrawnNFT(address indexed staker, uint256 indexed tokenId);
    event ColletedRewards(address indexed staker, uint256 indexed tokenId, uint256 rewardAmount);

    constructor(address _nftAddress) Ownable(msg.sender) {
        require(_nftAddress != address(0), "Zero address");
        nftAddress = _nftAddress;
    }

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

    function collect(uint256 tokenId) external {
        _collect(tokenId);
    }

    function bulkCollect(uint256[] calldata tokenIds) external {
        uint256 arrayLength = tokenIds.length;
        for (uint256 i = 0; i < arrayLength;) {
            _collect(tokenIds[i]);
            unchecked {
                i++;
            }
        }
    }

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
        uint256 rewardPeriods = (block.timestamp - oldStartTime) / 1 days;
        deposits[tokenId].startTime = oldStartTime + rewardPeriods * 1 days;

        emit ColletedRewards(msg.sender, tokenId, REWARD_AMT * rewardPeriods);
        RewardToken(tokenAddress).mintStakingRewards(msg.sender, REWARD_AMT * rewardPeriods);
    }

    function calcRewards(uint256 tokenId) public view returns (uint256) {
        Deposit memory deposit = deposits[tokenId];
        uint256 oldStartTime = deposit.startTime;
        uint256 rewardPeriods = (block.timestamp - oldStartTime) / 1 days;

        return REWARD_AMT * rewardPeriods;
    }
}
