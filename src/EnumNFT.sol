// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts//token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title EnumNFT
 * @author Ryan
 * @notice a simple Enumerable NFT with Openzeppelin lib
 */
contract EnumNFT is ERC721Enumerable {
    uint256 private constant MAX_SUPPLY = 20;

    constructor() ERC721("EnumNFT", "ENFT") {}

    /**
     *
     * @param tokenId specify the token Id to mint, Id should be within range [1, MAX_SUPPLY]
     */
    function safeMint(uint256 tokenId) external {
        require(tokenId <= MAX_SUPPLY, "Invaild tokenId to mint");
        require(tokenId > 0, "Invaild tokenId to mint");

        _safeMint(msg.sender, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId) || interfaceId == type(ERC721Enumerable).interfaceId;
    }
}
