// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "./ERC721FVerify.sol";

contract ERC721FVerifyImplementation is ERC721FVerify, ERC721F {
    address public immutable FREEMINT_CONTRACT;

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

    function claimToken(uint256 id) external {
        _verifyValidClaimer(id);
        _mint(msg.sender, id);
    }

    function _verifyValidClaimer(uint256 tokenId) private view {
        if (!verifyTokenOwner((FREEMINT_CONTRACT), tokenId)) {
            revert("Not a valid owner");
        }
    }
}
