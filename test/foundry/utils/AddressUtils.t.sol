// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/AddressUtilsMock.sol";

/**
 * @title AddressUtilsTest
 * @notice Regression suite for AddressUtils.calculateAddress.
 *
 * The known-answer vector is the public key of private key 1 — the
 * secp256k1 generator point G — whose address is vm.addr(1).
 *
 * calculateAddress must accept exactly two encodings:
 *  - 64 bytes: raw X||Y coordinates
 *  - 65 bytes: 0x04-prefixed uncompressed key (standard serialization)
 * Anything else must revert instead of silently returning a wrong address.
 */
contract AddressUtilsTest is Test {
    // Declared locally to reference the selectors; signatures (and therefore
    // selectors) match the errors declared in the AddressUtils library.
    error InvalidPublicKeyLength();
    error InvalidPublicKeyPrefix();

    AddressUtilsMock internal addressUtils;

    // Public key of private key 1 (secp256k1 generator point), raw X||Y.
    string internal constant PUBKEY_RAW =
        "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
        "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8";

    // Same key in standard uncompressed serialization (0x04 prefix).
    string internal constant PUBKEY_PREFIXED =
        "0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
        "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8";

    // Same key with an invalid prefix byte (0x05).
    string internal constant PUBKEY_BAD_PREFIX =
        "0579be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
        "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8";

    function setUp() public {
        addressUtils = new AddressUtilsMock();
    }

    // ─── valid encodings ─────────────────────────────────────────────────────

    function test_calculateAddress_rawKey() public {
        assertEq(addressUtils.calculateAddress(PUBKEY_RAW), vm.addr(1));
    }

    function test_calculateAddress_prefixedKey() public {
        assertEq(addressUtils.calculateAddress(PUBKEY_PREFIXED), vm.addr(1));
    }

    // ─── invalid input reverts ───────────────────────────────────────────────

    function test_calculateAddress_revertsOnTooShortKey() public {
        // 32 bytes — e.g. a hash or a compressed key missing its other half.
        vm.expectRevert(InvalidPublicKeyLength.selector);
        addressUtils.calculateAddress(
            "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
        );
    }

    function test_calculateAddress_revertsOnEmptyKey() public {
        vm.expectRevert(InvalidPublicKeyLength.selector);
        addressUtils.calculateAddress("");
    }

    function test_calculateAddress_revertsOnBadPrefix() public {
        vm.expectRevert(InvalidPublicKeyPrefix.selector);
        addressUtils.calculateAddress(PUBKEY_BAD_PREFIX);
    }

    // ─── existing hex-decoding behavior (regression guards) ─────────────────

    function test_calculateAddress_revertsOnOddLengthHexString() public {
        vm.expectRevert(AddressUtils.HexStringHasOddLength.selector);
        addressUtils.calculateAddress("abc");
    }

    function test_calculateAddress_revertsOnInvalidHexCharacter() public {
        vm.expectRevert(AddressUtils.InvalidHexCharacter.selector);
        addressUtils.calculateAddress(
            "zzbe667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
            "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8"
        );
    }
}
