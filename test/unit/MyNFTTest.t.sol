// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console, stdStorage, StdStorage} from "forge-std/Test.sol";
import {DeployMyNFT} from "../../script/DeployMyNFT.s.sol";
import {MyNFT} from "../../src/MyNFT.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyNFTTest is Test {
    uint256 private constant LOW_ETHER_VALUE = 0.005 ether;
    uint256 private constant NORMAL_ETHER_VALUE = 0.01 ether;
    uint256 private constant MAX_SUPPLY = 20;
    uint96 public constant ROYALTY = 250;

    MyNFT myNFT;
    address USER = address(0x1);
    bytes32[] proof1 = new bytes32[](3);

    using stdStorage for StdStorage;

    function setUp() public {
        DeployMyNFT deployer = new DeployMyNFT();
        myNFT = deployer.run();

        proof1[0] = 0x50bca9edd621e0f97582fa25f616d475cabe2fd783c8117900e5fed83ec22a7c;
        proof1[1] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof1[2] = 0x9005e06090901cdd6ef7853ac407a641787c28a78cb6327999fc51219ba3c880;
    }

    function testMintFailPrice() public {
        vm.expectRevert("Incorrect price");
        myNFT.mint{value: LOW_ETHER_VALUE}();
    }

    function testMintFailAllMinted() public {
        // set totalySupply to 20
        stdstore.target(address(myNFT)).sig(myNFT.totalSupply.selector).checked_write(MAX_SUPPLY);
        vm.expectRevert("All tokens minted");
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
    }

    function testNormalMint() public {
        vm.deal(USER, NORMAL_ETHER_VALUE);
        vm.prank(USER);
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
        assertEq(myNFT.balanceOf(USER), 1);
    }

    function testMintWithDiscountFailPrice() public {
        bytes32[] memory proof = new bytes32[](1);
        vm.expectRevert("Incorrect price");
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE / 2}(proof, 0);
    }

    function testMintWithDiscountAllMinted() public {
        bytes32[] memory proof = new bytes32[](1);
        // set totalySupply to 20
        stdstore.target(address(myNFT)).sig(myNFT.totalSupply.selector).checked_write(20);
        vm.expectRevert("All tokens minted");
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof, 0);
    }

    function testValidDiscountProof() public {
        uint256 index = 0;
        vm.deal(USER, LOW_ETHER_VALUE);
        vm.prank(USER);
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof1, index);

        assertEq(myNFT.balanceOf(USER), 1);
    }

    function testInvalidDiscountProof() public {
        bytes32[] memory proof = new bytes32[](3);

        uint256 index = 0;
        vm.deal(USER, LOW_ETHER_VALUE);
        vm.prank(USER);
        vm.expectRevert("Invalid proof");
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof, index);
    }

    function testAttemptDoubleDiscount() public {
        uint256 index = 0;
        vm.deal(USER, LOW_ETHER_VALUE);
        vm.prank(USER);
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof1, index);

        vm.deal(USER, LOW_ETHER_VALUE);
        vm.prank(USER);
        vm.expectRevert("Discount already used");
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof1, index);
    }

    function testWidthDrawBalance() public {
        vm.startPrank(USER);
        vm.deal(USER, NORMAL_ETHER_VALUE * 2);
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
        vm.stopPrank();

        assertEq(address(myNFT).balance, NORMAL_ETHER_VALUE * 2);

        vm.prank(msg.sender);
        uint256 balanceBefore = msg.sender.balance;
        myNFT.widthDrawBalance();
        uint256 balanceAfter = msg.sender.balance;

        assertEq(balanceAfter - balanceBefore, NORMAL_ETHER_VALUE * 2);
    }

    function testWidthDrawBalanceNotOwner() public {
        vm.startPrank(USER);
        vm.deal(USER, NORMAL_ETHER_VALUE * 2);
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
        myNFT.mint{value: NORMAL_ETHER_VALUE}();
        vm.stopPrank();

        assertEq(address(myNFT).balance, NORMAL_ETHER_VALUE * 2);

        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        myNFT.widthDrawBalance();
    }

    function testSupportsInterface() public {
        assertEq(myNFT.supportsInterface(0x80ac58cd), true);
        assertEq(myNFT.supportsInterface(0x01ffc9a7), true);
        assertEq(myNFT.supportsInterface(0x780e9d63), false);
    }

    function testRoyaltyInfo() external {
        uint256 index = 0;
        vm.deal(USER, LOW_ETHER_VALUE);
        vm.prank(USER);
        myNFT.mintWithDiscount{value: LOW_ETHER_VALUE}(proof1, index);

        // show the nft royalty info
        (address receiver, uint256 royaltyAmount) = myNFT.royaltyInfo(0, LOW_ETHER_VALUE);
        assertEq(receiver, msg.sender);
        assertEq(royaltyAmount, LOW_ETHER_VALUE * ROYALTY / 10_000);
    }
}
