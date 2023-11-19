// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {PrimeCounter} from "../src/PrimeCounter.sol";
import {EnumNFT} from "../src/EnumNFT.sol";

contract DeployPrimeCounter is Script {
    function run() external returns (EnumNFT, PrimeCounter) {
        vm.startBroadcast();
        EnumNFT nft = new EnumNFT();
        PrimeCounter primeCounter = new PrimeCounter();
        vm.stopBroadcast();
        return (nft, primeCounter);
    }
}
