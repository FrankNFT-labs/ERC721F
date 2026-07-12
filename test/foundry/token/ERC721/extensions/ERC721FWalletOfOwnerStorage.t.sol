// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../../lib/forge-std/src/Test.sol";
import "../../../../../contracts/mocks/ERC721FWalletOfOwnerStorageMock.sol";

/**
 * @title ERC721FWalletOfOwnerStorageTest
 * @notice Characterization suite for ERC721FWalletOfOwnerStorage.sol, written
 * before the _removeTokenFromWallet refactor to lock in behavior and serve as
 * the gas baseline (forge snapshot).
 *
 * The mock mints to msg.sender, so the test contract holds the tokens and
 * transfers directly as the token owner.
 */
contract ERC721FWalletOfOwnerStorageTest is Test {
    ERC721FWalletOfOwnerStorageMock internal token;
    address internal bob;

    function setUp() public {
        token = new ERC721FWalletOfOwnerStorageMock("WalletStorage", "WOS");
        bob = makeAddr("bob");
    }

    function test_walletOfOwner_tracksMints() public {
        token.mint(3);
        uint256[] memory wallet = token.walletOfOwner(address(this));
        assertEq(wallet.length, 3);
        assertEq(wallet[0], 0);
        assertEq(wallet[1], 1);
        assertEq(wallet[2], 2);
    }

    function test_transfer_movesTokenBetweenWallets() public {
        token.mint(2);
        token.transferFrom(address(this), bob, 0);
        assertEq(token.walletOfOwner(address(this)).length, 1);
        uint256[] memory bobWallet = token.walletOfOwner(bob);
        assertEq(bobWallet.length, 1);
        assertEq(bobWallet[0], 0);
    }

    function test_removal_swapsLastTokenIntoPlace() public {
        token.mint(5); // wallet: [0,1,2,3,4]
        token.transferFrom(address(this), bob, 1);
        uint256[] memory wallet = token.walletOfOwner(address(this));
        assertEq(wallet.length, 4);
        assertEq(wallet[0], 0);
        assertEq(wallet[1], 4); // last token swapped into the freed slot
        assertEq(wallet[2], 2);
        assertEq(wallet[3], 3);
    }

    function test_burn_removesTokenFromWallet() public {
        token.mint(2);
        token.burn(0);
        uint256[] memory wallet = token.walletOfOwner(address(this));
        assertEq(wallet.length, 1);
        assertEq(wallet[0], 1);
    }

    // ─── gas anchors (compared via forge snapshot before/after refactor) ────

    function test_gas_transferFromWalletOf50() public {
        token.mint(50);
        token.transferFrom(address(this), bob, 49); // full scan to last slot
    }

    function test_gas_burnFromWalletOf50() public {
        token.mint(50);
        token.burn(49); // full scan to last slot
    }
}
