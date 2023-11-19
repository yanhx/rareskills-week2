// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts//token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeCounter {
    function countPrimes(address holder, address nftAddress) public view returns (uint256) {
        // get token count for holder
        uint256 count = ERC721Enumerable(nftAddress).balanceOf(holder);
        uint256 primeCount = 0;

        for (uint256 i; i < count;) {
            uint256 tokenId = ERC721Enumerable(nftAddress).tokenOfOwnerByIndex(holder, i);
            if (_isPrime(tokenId)) {
                unchecked {
                    primeCount++;
                }
            }
            unchecked {
                i++;
            }
        }

        return primeCount;
    }

    function _isPrime(uint256 n) private pure returns (bool) {
        if (n < 2) return false;
        if (n == 2) return true;
        if (n % 2 == 0) return false;

        for (uint256 i = 3; i * i <= n;) {
            if (n % i == 0) return false;
            unchecked {
                i += 2;
            }
        }
        return true;
    }
}
