// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MyNFT is ERC721, ERC2981, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant PRICE = 0.01 ether;
    uint256 public constant DISCOUNTED_PRICE = 0.005 ether;
    uint96 public constant ROYALTY = 250; // basis points
    bytes32 public immutable i_merkleRoot;
    uint256 public totalSupply;

    BitMaps.BitMap private discountList;

    constructor(bytes32 _merkleRoot) ERC721("MyNFT", "MYNFT") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, ROYALTY);
        i_merkleRoot = _merkleRoot;
    }

    function mint() public payable {
        require(msg.value >= PRICE, "Incorrect price");
        require(totalSupply < MAX_SUPPLY, "All tokens minted");

        _safeMint(msg.sender, totalSupply);
        totalSupply++;
    }

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
