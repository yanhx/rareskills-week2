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

    /**
     * @dev Returns true if the given number is a prime number. This primality test makes use of the fact that
     * it's sufficient to test whether the number is divisible by 2 or 3, and then to only check through all numbers of
     * the form 6k ± 1 up to the square root of the given number.
     * Further reading: https://en.wikipedia.org/wiki/Primality_test
     * @param _number The number to be checked for primality.
     * @return A boolean indicating whether the given number is prime or not.
     */
    function _isPrime(uint256 _number) private pure returns (bool) {
        if (_number <= 3) {
            return _number > 1;
        } else if (_number % 2 == 0) {
            return false;
        } else if (_number % 3 == 0) {
            return false;
        } else {
            for (uint256 i = 5; i * i <= _number; i = i + 6) {
                if (_number % i == 0) {
                    return false;
                } else if (_number % (i + 2) == 0) {
                    return false;
                }
            }
            return true;
        }
    }
}
