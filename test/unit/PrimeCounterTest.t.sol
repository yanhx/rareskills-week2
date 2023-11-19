// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployPrimeCounter} from "../../script/DeployPrimeCounter.s.sol";
import {PrimeCounter} from "../../src/PrimeCounter.sol";
import {EnumNFT} from "../../src/EnumNFT.sol";

contract PrimeCounterTest is Test {
    EnumNFT nft;
    PrimeCounter primeCounter;

    address USER = makeAddr("user");

    function setUp() public {
        DeployPrimeCounter deployer = new DeployPrimeCounter();
        (nft, primeCounter) = deployer.run();
    }

    function testPrimeCounter() public {
        vm.startPrank(USER);
        for (uint256 i; i < 20; i++) {
            nft.safeMint(i + 1);
        }
        vm.stopPrank();

        assertEq(primeCounter.countPrimes(USER, address(nft)), 8);
    }
}
