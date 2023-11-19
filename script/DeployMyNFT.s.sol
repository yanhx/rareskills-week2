// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract DeployMyNFT is Script {
    function run() external returns (MyNFT) {
        vm.startBroadcast();
        bytes32 merkleRoot = 0x897d6714686d83f84e94501e5d6f0f38c94b75381b88d1de3878b4f3d2d5014a;
        MyNFT myNFT = new MyNFT(merkleRoot);
        vm.stopBroadcast();
        return myNFT;
    }
}
