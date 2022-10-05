// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/ERC721F.sol";
import "hardhat/console.sol";

/**
 * @title ERC721FGasReporterMock
 * @dev Extends ERC721
 * Contains massmint and -transfer methods to test gasconsumption of ERC721F.
 */

contract ERC721FGasReporterMock is ERC721F {
    constructor(string memory name_, string memory symbol_)
        ERC721F(name_, symbol_)
    {}

    /**
     * @notice Mints a single token
     */
    function mintOne(address to) public {
        mint(to, 1);
    }

    /**
     * @notice Mints ten tokens
     */
    function mintTen(address to) public {
        mint(to, 10);
    }

    /**
     * @notice Mints a hundred tokens
     */
    function mintHundred(address to) public {
        mint(to, 100);
    }

    /**
     * @notice Mints any number of tokens and transfers them to `to`
     */
    function mint(address to, uint256 numberOfTokens) internal {
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < numberOfTokens; ) {
            _mint(to, supply + i);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Transfers the first token owned by the sender to `to`
     */
    function transferOneAsc(address to) public {
        transferFrom(msg.sender, to, retrieveFirstToken());
    }

    /**
     * @notice Transfers the last token owned by the sender to `to`
     */
    function transferOneDesc(address to) public {
        transferFrom(msg.sender, to, retrieveLastToken());
    }

    /**
     * @notice Transfers the first token owned by the sender to `to`, does this ten times
     */
    function transferTenAsc(address to) public {
        for (uint i = 0; i < 10; ) {
            transferFrom(msg.sender, to, retrieveFirstToken());
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Transfers the last token owned by the sender to `to`, does this ten times
     */
    function transferTenDesc(address to) public {
        for (uint i = 0; i < 10; ) {
            transferFrom(msg.sender, to, retrieveLastToken());
            unchecked {
                ++i;
            }
        }
    }


    /**
     * @notice Transfers the first token owned by the sender to `to`, does this fifty times
     */
    function transferFiftyAsc(address to) public {
        for (uint i = 0; i < 50; ) {
            transferFrom(msg.sender, to, retrieveFirstToken());
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Transfers the last token owned by the sender to `to`, does this fifty times
     */
    function transferFiftyDesc(address to) public {
        for (uint i = 0; i < 50; ) {
            transferFrom(msg.sender, to, retrieveLastToken());
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Returns first id that is encountered which is owned by the sender
     */
    function retrieveFirstToken()
        internal
        view
        returns (uint firstOwnedTokenId)
    {
        uint totalSupply = totalSupply();
        for (uint i = 0; i < totalSupply; ) {
            if (ownerOf(i) == msg.sender) {
                return i;
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Returns last id that is encountered which is owned by the sender
     */
    function retrieveLastToken() internal view returns (uint lastOwnedTokenId) {
        uint totalSupply = totalSupply();
        for (uint i = totalSupply - 1; i > 0; ) {
            if (ownerOf(i) == msg.sender) {
                return i;
            }
            unchecked {
                --i;
            }
        }
    }
}
