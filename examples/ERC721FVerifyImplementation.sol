// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "./ERC721FVerify.sol";

contract ERC721FVerifyImplementation is ERC721FVerify, ERC721F {
    address public immutable FREEMINT_CONTRACT;
    bool public saleIsActive;

    modifier validMintRequest() {
        require(msg.sender == tx.origin, "No contracts allowed");
        _;
    }

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

    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function mint(uint256 tokenId) external validMintRequest {
        require(saleIsActive, "SALE is not active yet");
        _mint(msg.sender, tokenId);
    }

    function mintDelegated(
        uint256 tokenId,
        address recipient
    ) external validMintRequest {
        require(saleIsActive, "SALE is not active yet");
        _delegatedMint(tokenId, recipient);
    }

    function preSaleMint(uint256 tokenId) external validMintRequest {
        require(ERC721FVerify.hasPreSalePermissions(FREEMINT_CONTRACT));
        _mint(msg.sender, tokenId);
    }

    function _delegatedMint(uint256 tokenId, address recipient) internal {
        require(
            ERC721FVerify.isValidClaimer(address(this), recipient),
            "Not delegated by recipient"
        );
        _mint(recipient, tokenId);
    }
}
