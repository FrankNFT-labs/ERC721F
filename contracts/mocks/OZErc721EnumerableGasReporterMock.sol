// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title OZErc721EnumerableGasReporterMock
 * @dev Mirrors ERC721FGasReporterMock interface using plain OZ ERC721 + ERC721Enumerable.
 * Used exclusively for gas comparison benchmarks against ERC721F.
 *
 * ERC721F replaces ERC721Enumerable — this is the canonical "before" baseline.
 * Transfer helpers use tokenOfOwnerByIndex() (O(1)) which is the Enumerable advantage.
 */
contract OZErc721EnumerableGasReporterMock is ERC721Enumerable {
    uint256 private _nextTokenId;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    // -------------------------------------------------------------------------
    // Mint helpers
    // -------------------------------------------------------------------------

    function mintOne(address to) public {
        _mintBatch(to, 1);
    }

    function mintTen(address to) public {
        _mintBatch(to, 10);
    }

    function mintHundred(address to) public {
        _mintBatch(to, 100);
    }

    // -------------------------------------------------------------------------
    // Transfer helpers (mirrors ERC721FGasReporterMock)
    // -------------------------------------------------------------------------

    /// @notice Transfers the first token owned by the sender (ascending order via index 0)
    function transferOneAsc(address to) public {
        transferFrom(msg.sender, to, tokenOfOwnerByIndex(msg.sender, 0));
    }

    /// @notice Transfers the last token owned by the sender (descending order via last index)
    function transferOneDesc(address to) public {
        uint256 last = balanceOf(msg.sender) - 1;
        transferFrom(msg.sender, to, tokenOfOwnerByIndex(msg.sender, last));
    }

    /// @notice Transfers the first token ten times
    function transferTenAsc(address to) public {
        unchecked {
            for (uint256 i = 0; i < 10; ) {
                transferFrom(
                    msg.sender,
                    to,
                    tokenOfOwnerByIndex(msg.sender, 0)
                );
                i++;
            }
        }
    }

    /// @notice Transfers the last token ten times
    function transferTenDesc(address to) public {
        unchecked {
            for (uint256 i = 0; i < 10; ) {
                uint256 last = balanceOf(msg.sender) - 1;
                transferFrom(
                    msg.sender,
                    to,
                    tokenOfOwnerByIndex(msg.sender, last)
                );
                i++;
            }
        }
    }

    /// @notice Transfers the first token fifty times
    function transferFiftyAsc(address to) public {
        unchecked {
            for (uint256 i = 0; i < 50; ) {
                transferFrom(
                    msg.sender,
                    to,
                    tokenOfOwnerByIndex(msg.sender, 0)
                );
                i++;
            }
        }
    }

    /// @notice Transfers the last token fifty times
    function transferFiftyDesc(address to) public {
        unchecked {
            for (uint256 i = 0; i < 50; ) {
                uint256 last = balanceOf(msg.sender) - 1;
                transferFrom(
                    msg.sender,
                    to,
                    tokenOfOwnerByIndex(msg.sender, last)
                );
                i++;
            }
        }
    }

    // -------------------------------------------------------------------------
    // Internal
    // -------------------------------------------------------------------------

    function _mintBatch(address to, uint256 count) internal {
        uint256 startId = _nextTokenId;
        unchecked {
            for (uint256 i = 0; i < count; ) {
                _mint(to, startId + i);
                i++;
            }
            _nextTokenId = startId + count;
        }
    }
}
