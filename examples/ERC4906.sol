// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "../contracts/interfaces/IERC4906.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ERC4906 is ERC721F, IERC4906, ERC721URIStorage {
    uint256 public constant MAX_TOKENS = 10000;
    bool public saleIsActive;

    constructor() ERC721F("Example Metadata Update Extension", "EMUE") {}

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
    ) public view virtual override(IERC165, ERC721) returns (bool) {
        return
            _interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
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
    function mint(uint256 tokenId, string memory _tokenURI) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(!_exists(tokenId), "Token already exists");
        require(
            totalSupply() <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        _mint(msg.sender, tokenId);
        super._setTokenURI(tokenId, _tokenURI);
    }

    /**
     * @notice Sets the tokenURI of `tokenId` to `_tokenURI`
     * @dev Requires caller to be owner of `tokenId`
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual override  {
        require(ownerOf(tokenId) == msg.sender, "Caller is not owner of token");
        super._setTokenURI(tokenId, _tokenURI);
        emit MetadataUpdate(tokenId);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual override(ERC721, ERC721F) returns (string memory) {
        return ERC721F._baseURI();
    }

    /**
     *
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     */
    function _mint(address to, uint256 tokenId) internal virtual override(ERC721, ERC721F) {
        ERC721F._mint(to, tokenId);
    }

    /**
     * @dev See {ERC721URIStorage-_burn}
     */
    function _burn(uint256 tokenId) internal virtual override(ERC721URIStorage, ERC721F) {
        ERC721URIStorage._burn(tokenId);
    }
}
