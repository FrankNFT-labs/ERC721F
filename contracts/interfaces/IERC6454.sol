/// @title EIP-6454 Minimalistic Non-Transferable interface for NFTs
/// @dev See https://eips.ethereum.org/EIPS/eip-6454
/// @dev Note: the ERC-165 identifier for this interface is 0x91a6262f.

pragma solidity ^0.8.16;

/* is IERC165 */ interface IERC6454 {
    /**
     * @notice Used to check whether the given token is transferable or not.
     * @dev If this function returns `false`, the transfer of the token MUST revert execution.
     * @dev If the tokenId does not exist, this method MUST revert execution, unless the token is being checked for
     *  minting.
     * @dev The `from` parameter MAY be used to also validate the approval of the token for transfer, but anyone
     *  interacting with this function SHOULD NOT rely on it as it is not mandated by the proposal.
     * @param tokenId ID of the token being checked
     * @param from Address from which the token is being transferred
     * @param to Address to which the token is being transferred
     * @return Boolean value indicating whether the given token is transferable
     */
    function isTransferable(
        uint256 tokenId,
        address from,
        address to
    ) external view returns (bool);
}
