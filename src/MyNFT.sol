// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MyNFT
 * @author Ryan
 * @notice an ERC721 NFT,  a reward rate of 2.5% for any NFT in the collection. Addresses in a merkle tree can mint NFTs at a discount.
 *
 */
contract MyNFT is ERC721, ERC2981, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant PRICE = 0.01 ether;
    uint256 public constant DISCOUNTED_PRICE = 0.005 ether;
    uint96 public constant ROYALTY = 250; // basis points

    //Merkle tree root for discount address list
    bytes32 public immutable i_merkleRoot;

    uint256 public totalSupply;

    //bitmap stores discount usage info, false -> unused , true -> used
    BitMaps.BitMap private discountList;

    constructor(bytes32 _merkleRoot) ERC721("MyNFT", "MYNFT") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, ROYALTY);
        i_merkleRoot = _merkleRoot;
    }

    /**
     * NTF is minted from Id 0 to larger Id continously
     */
    function mint() public payable {
        require(msg.value >= PRICE, "Incorrect price");
        require(totalSupply < MAX_SUPPLY, "All tokens minted");

        _safeMint(msg.sender, totalSupply);
        totalSupply++;
    }

    /**
     * Mint NFT with discounted price, one chance per address in discount list merkle tree
     * @param proof merkle proof path
     * @param index address index in merkle tree
     */
    function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable {
        require(totalSupply < MAX_SUPPLY, "All tokens minted");
        require(!BitMaps.get(discountList, index), "Discount already used");
        require(msg.value >= DISCOUNTED_PRICE, "Incorrect price");

        _verifyProof(proof, index);

        // set discount as used
        BitMaps.setTo(discountList, index, true);

        _safeMint(msg.sender, totalSupply);

        totalSupply++;
    }

    /**
     * Withdraw all fund received from NFT minting
     */
    function widthDrawBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return interfaceId == type(ERC2981).interfaceId || interfaceId == type(ERC721).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function _verifyProof(bytes32[] memory proof, uint256 index) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, index))));
        require(MerkleProof.verify(proof, i_merkleRoot, leaf), "Invalid proof");
    }
}
