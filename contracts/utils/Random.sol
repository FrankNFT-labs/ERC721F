// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

/**
 * @title Random
 * @dev A contract that provides pseudo-random number generation functionality.
 * @author @FrankNFT.eth
 */

abstract contract Random {
    uint256 private nonce;

    /**
     * @notice Generates a pseudo-random number using the PrevranDAO.
     * @dev This implementation is a simple random number generator that takes into account
     * the current block timestamp, previous random value, counter, and sender address.
     * @return A pseudo-random 256-bit integer.
     */
    function random() internal returns (uint256) {
        unchecked {
            nonce++;
        }
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        nonce,
                        msg.sender
                    )
                )
            );
    }

    /**
     * @notice Generates a pseudo-random number using the PrevranDAO with an additional seed value.
     * @dev This implementation allows for an extra seed value to be injected, increasing the entropy
     *      of the generated random number. It takes into account the current block timestamp,
     *      previous random value, counter, seed, and sender address.
     * @param seed An additional 256-bit integer value to be used in the random number generation.
     * @return A pseudo-random 256-bit integer.
     */
    function random(uint256 seed) internal returns (uint256) {
        unchecked {
            nonce++;
        }
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        nonce,
                        seed,
                        msg.sender
                    )
                )
            );
    }
}
