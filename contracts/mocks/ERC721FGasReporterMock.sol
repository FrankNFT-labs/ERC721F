// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/ERC721F.sol";

/**
 * @title ERC721FGasReporterMock
 * @dev Extends ERC721
 * Contains massmint and -transfer methods to test gasconsumption of ERC721F.
 */

contract ERC721FGasReporterMock is ERC721F {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721F(name_, symbol_) {}

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
        uint256 supply = _totalMinted();
        unchecked {
            for (uint256 i; i < numberOfTokens; ) {
                _mint(to, supply + i);
                i++;
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
        unchecked {
            for (uint i = 0; i < 10; ) {
                transferFrom(msg.sender, to, retrieveFirstToken());
                i++;
            }
        }
    }

    /**
     * @notice Transfers the last token owned by the sender to `to`, does this ten times
     */
    function transferTenDesc(address to) public {
        unchecked {
            for (uint i = 0; i < 10; ) {
                transferFrom(msg.sender, to, retrieveLastToken());
                i++;
            }
        }
    }

    /**
     * @notice Transfers the first token owned by the sender to `to`, does this fifty times
     */
    function transferFiftyAsc(address to) public {
        unchecked {
            for (uint i = 0; i < 50; ) {
                transferFrom(msg.sender, to, retrieveFirstToken());
                i++;
            }
        }
    }

    /**
     * @notice Transfers the last token owned by the sender to `to`, does this fifty times
     */
    function transferFiftyDesc(address to) public {
        unchecked {
            for (uint i = 0; i < 50; ) {
                transferFrom(msg.sender, to, retrieveLastToken());
                i++;
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
        uint256 totalSupply = _totalMinted();
        unchecked {
            for (uint256 i = 0; i < totalSupply; ) {
                if (ownerOf(i) == msg.sender) {
                    return i;
                }
                i++;
            }
        }
    }

    /**
     * @dev Returns last id that is encountered which is owned by the sender
     */
    function retrieveLastToken() internal view returns (uint lastOwnedTokenId) {
        uint256 totalSupply = _totalMinted();
        unchecked {
            for (uint256 i = totalSupply - 1; i >= 0; ) {
                if (ownerOf(i) == msg.sender) {
                    return i;
                }
                i--;
            }
        }
    }
}
