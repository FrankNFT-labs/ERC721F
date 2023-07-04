// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

library ERC721FStorage {
    struct Layout {
        // =============================================================
        //                        ERC721 STORAGE
        // =============================================================

        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;
        // Mapping owner address to token count
        mapping(address => uint256) _balances;
        // Mapping from token ID to approved address
        mapping(uint256 => address) _tokenApprovals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;
        // =============================================================
        //                        ERC721F STORAGE
        // =============================================================

        // Total tokens minted
        uint256 _tokenSupply;
        // Total tokens burned
        uint256 _burnCounter;
        // Base URI for Meta data
        string _baseTokenURI;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("ERC721F.contracts.storage.ERC721F");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
