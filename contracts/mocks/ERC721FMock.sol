// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/ERC721F.sol";

contract ERC721FMock is ERC721F {
    constructor(string memory name_, string memory symbol_)
        ERC721F(name_, symbol_)
    {}

    /**
     * @notice Mint your tokens here
     * @dev Function utilised in testing, don't use in production due to lack of restrictions
     */
    function mint(uint256 numberOfTokens) public {
        uint256 supply = totalSupply();
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i);
            unchecked {
                i++;
            }
        }
    }
}