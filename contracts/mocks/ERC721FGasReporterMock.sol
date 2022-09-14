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
                i++;
            }
        }
    }

    /**
     * @notice Retrieves the wallet of the sender and transfers the first token stored to `to`
     */
    function transferOneAsc(address to) public {
        transferFrom(msg.sender, to, this.walletOfOwner(msg.sender)[0]);
    }

    /**
     * @notice Retrieves the wallet of the sender and transfers the last token stored to `to`
     */
    function transferOneDesc(address to) public {
        uint256[] memory walletOfOwner = this.walletOfOwner(msg.sender);
        uint walletSize = walletOfOwner.length;
        transferFrom(msg.sender, to, walletOfOwner[walletSize - 1]);
    }


    /**
     * @notice Retrieves the wallet of the sender, retrieves the first stored token and transfers it to `to` this happens ten times
     */
    function transferTenAsc(address to) public {
        uint256[] memory walletOfOwner = this.walletOfOwner(msg.sender);
        for (uint i = 0; i < 10; ) {
            transferFrom(msg.sender, to, walletOfOwner[i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Retrieves the wallet of the sender, retrieves the last stored token and transfers it to `to` this happens ten times
     */
    function transferTenDesc(address to) public {
        uint256[] memory walletOfOwner = this.walletOfOwner(msg.sender);
        uint walletSize = walletOfOwner.length;
        for (uint i = 0; i < 10; ) {
            transferFrom(msg.sender, to, walletOfOwner[(walletSize - 1) - i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Retrieves the wallet of the sender, retrieves the first stored token and transfers it to `to` this happens fifty times
     */
    function transferFiftyAsc(address to) public {
        uint256[] memory walletOfOwner = this.walletOfOwner(msg.sender);
        for (uint i = 0; i < 50; ) {
            transferFrom(msg.sender, to, walletOfOwner[i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Retrieves the wallet of the sender, retrieves the last stored token and transfers it to `to` this happens fifty times
     */
    function transferFiftyDesc(address to) public {
        uint256[] memory walletOfOwner = this.walletOfOwner(msg.sender);
        uint walletSize = walletOfOwner.length;
        for (uint i = 0; i < 50; ) {
            transferFrom(msg.sender, to, walletOfOwner[(walletSize - 1) - i]);
            unchecked {
                i++;
            }
        }
    }
}
