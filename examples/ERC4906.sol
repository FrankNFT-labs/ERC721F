// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ERC4906 is ERC721F, ERC721URIStorage {
    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31; // Theoretical limit 1100
    bool public saleIsActive;

    constructor() ERC721F("Example Metadata Update Extension", "EMUE", msg.sender) {}

    /**
     * @notice Indicates whether this contract supports an interface
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * @return `true` if the contract implements `interfaceID` or is 0x49064906, `false` otherwise
     */
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return
            ERC721URIStorage.supportsInterface(_interfaceId);
    }

    /**
     * @dev See {ERC721URIStorage-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    /**
     * Changes the state of saleIsActive from true to false and false to true
     */
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * Mint your tokens here.
     */
    function mint(uint256 numberOfTokens, string memory _tokenURI) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens > 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = _totalMinted();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        unchecked {
            for (uint256 i; i < numberOfTokens; ) {
                uint256 nextTokenId = supply + i;
                _mint(msg.sender, nextTokenId); // no need to use safeMint as we don't allow contracts.
                super._setTokenURI(nextTokenId, _tokenURI);
                i++;
            }
        }
    }

    /**
     * @dev Sets the tokenURI of `tokenId` to `_tokenURI`
     */
    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual override {
        require(ownerOf(tokenId) == msg.sender, "Caller is not owner of token");
        super._setTokenURI(tokenId, _tokenURI);
        emit MetadataUpdate(tokenId);
    }

    /**
     * @dev Sets the tokenURI of tokens from `_fromTokenId` to `to` to `_toTokenId`
     */
    function _setTokenURIS(
        uint256 _fromTokenId,
        uint256 _toTokenId,
        string memory _tokenURI
    ) internal virtual {
        unchecked {
            for (uint256 i = _fromTokenId; i <= _toTokenId; ) {
                if (_exists(i)) {
                    require(
                        ownerOf(i) == msg.sender,
                        "Caller is not owner of token"
                    );
                    super._setTokenURI(i, _tokenURI);
                }
                i++;
            }
        }
        emit BatchMetadataUpdate(_fromTokenId, _toTokenId);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI()
        internal
        view
        virtual
        override(ERC721, ERC721F)
        returns (string memory)
    {
        return ERC721F._baseURI();
    }

    /**
     * @dev See {ERC721F-_burn}
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721, ERC721F) returns (address) {
        return ERC721F._update(to, tokenId, auth);
    }
}
