// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../token/ERC721/extensions/ERC721FOnChain.sol";

/**
 * @title ERC721FOnChainMock
 * @dev Mock with deterministic SVG and trait overrides so the exact tokenURI
 * composition of ERC721FOnChain can be asserted. `setHasTraits(false)`
 * switches getTraits to an empty string to exercise the no-attributes branch.
 */
contract ERC721FOnChainMock is ERC721FOnChain {
    bool private _hasTraits = true;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory description_
    ) ERC721FOnChain(name_, symbol_, msg.sender, description_) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function setHasTraits(bool hasTraits_) public {
        _hasTraits = hasTraits_;
    }

    function renderTokenById(
        uint256 id
    ) public view virtual override returns (string memory) {
        return
            string(abi.encodePacked("<svg>", Strings.toString(id), "</svg>"));
    }

    function getTraits(
        uint256 id
    ) public view virtual override returns (string memory) {
        if (!_hasTraits) {
            return "";
        }
        return
            string(
                abi.encodePacked(
                    '[{"trait_type": "Id", "value": "',
                    Strings.toString(id),
                    '"}]'
                )
            );
    }
}
