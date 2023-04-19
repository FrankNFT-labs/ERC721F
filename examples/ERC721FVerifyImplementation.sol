// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@franknft.eth/erc721-f/contracts/token/ERC721/ERC721F.sol";
import "./ERC721FVerify.sol";

/**
 * @title ERC721FVerifyImplementation
 * @dev Example implemenation of ERC721FVerify to only allow mints when owning tokens in FreeMint
 */
contract ERC721FVerifyImplementation is ERC721FVerify, ERC721F {
    address public immutable FREEMINT_CONTRACT;

    /**
     * @param _warmContract address to deployed HotWalletProxy
     * @param _delegateCashContract address to deployed DelegationRegistry
     * @param _freeMintContract address to deployed FreeMint
     */
    constructor(
        address _warmContract,
        address _delegateCashContract,
        address _freeMintContract
    )
        ERC721FVerify(_warmContract, _delegateCashContract)
        ERC721F("test", "test")
    {
        FREEMINT_CONTRACT = _freeMintContract;
    }

    /**
     * @notice Mints `tokenId`
     * @param TokenId to be minted
     * @dev msg.sender must have tokens within the FreeMint contract
     */
    function mint(uint256 tokenId) external {
        require(
            ERC721FVerify.hasTokens(FREEMINT_CONTRACT),
            "Must have tokens in FreeMint"
        );
        _mint(msg.sender, tokenId);
    }
}
