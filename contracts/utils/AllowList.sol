// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library AllowList {
    function recoverSigner(bytes32 hash, bytes memory signature) public pure returns(address) {
        bytes32 messageDigest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            hash
        ));
        return ECDSA.recover(messageDigest, signature);
    }
}