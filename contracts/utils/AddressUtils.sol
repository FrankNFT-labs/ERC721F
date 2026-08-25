// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

/**
 * @title AddressUtils
 * @dev A collection of utility functions related to the address type.
 * @author FrankNFT.eth
 */
library AddressUtils {
    error InvalidHexCharacter();
    error HexStringHasOddLength();
    error InvalidPublicKeyLength();
    error InvalidPublicKeyPrefix();

    /**
     * @notice Checks if the provided address is a contract.
     * !!!! It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract !!!!
     * @dev This function checks the size of the code at the given address.
     * @param _address The address to check.
     * @return bool Returns true if the address is a contract, false otherwise.
     */
    function _isContract(address _address) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }

    /**
     * @dev Generates a pseudo-random address.
     *
     * This function creates a pseudo-random address by hashing the current block timestamp
     * and the previous block's random number (prevrandao). The resulting hash is then
     * converted to a uint256, cast to a uint160, and finally to an address.
     *
     * @param nonce An integer value to introduce additional variability to the hash.
     * @return addr A pseudo-randomly generated address.
     */
    function randomAddress(int256 nonce) internal view returns (address addr) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                block.timestamp,
                                block.prevrandao,
                                nonce
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev Generates a pseudo-random address.
     * This function is deprecated and should not be used. Instead, use the function with the
     * `nonce` parameter to introduce additional randomness.
     *
     * This function creates a pseudo-random address by hashing the current block timestamp
     * and the previous block's random number (prevrandao). The resulting hash is then
     * converted to a uint256, cast to a uint160, and finally to an address.
     *
     * @return addr A pseudo-randomly generated address.
     */
    function randomAddress() internal view returns (address addr) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(block.timestamp, block.prevrandao)
                        )
                    )
                )
            );
    }

    /**
     * @notice Calculates an Ethereum address from a given public key.
     * @param publicKey The public key as a hex string (no "0x" prefix), either
     * 64 bytes of raw X||Y coordinates or the 65-byte uncompressed
     * serialization starting with 0x04. Any other input reverts, since hashing
     * it would silently produce an address nobody holds the key for.
     * @return addr The calculated Ethereum address.
     */
    function calculateAddress(
        string memory publicKey
    ) internal pure returns (address addr) {
        // Convert the hex string to bytes
        bytes memory publicKeyBytes = hexStringToBytes(publicKey);
        uint256 length = publicKeyBytes.length;

        // Compute the hash of the 64-byte X||Y payload
        bytes32 publicKeyHash;
        if (length == 64) {
            publicKeyHash = keccak256(publicKeyBytes);
        } else if (length == 65) {
            if (publicKeyBytes[0] != 0x04) revert InvalidPublicKeyPrefix();
            // Hash the 64 bytes after the 0x04 prefix (data starts at 0x20,
            // +1 to skip the prefix byte)
            // solhint-disable-next-line no-inline-assembly
            assembly {
                publicKeyHash := keccak256(add(publicKeyBytes, 0x21), 64)
            }
        } else {
            revert InvalidPublicKeyLength();
        }

        // Take the last 40 characters (20 bytes) of the public key hash and convert to an address
        addr = address(uint160(uint256(publicKeyHash)));

        return addr;
    }

    /**
     * @notice Converts a hex character to its integer value.
     * @param c The hex character.
     * @return The integer value.
     */
    function fromHexChar(uint8 c) internal pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        }
        if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
            return 10 + c - uint8(bytes1("A"));
        }
        revert InvalidHexCharacter();
    }

    /**
     * @notice Converts a hex string to a bytes array.
     * @param s The hex string.
     * @return The bytes array.
     */
    function hexStringToBytes(
        string memory s
    ) internal pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        if (ss.length % 2 != 0) revert HexStringHasOddLength();
        bytes memory r = new bytes(ss.length / 2);
        for (uint256 i = 0; i < ss.length / 2;) {
            r[i] = bytes1(
                fromHexChar(uint8(ss[2 * i])) * 16 +
                    fromHexChar(uint8(ss[2 * i + 1]))
            );
            unchecked {
                i++;
            }
        }
        return r;
    }
}
