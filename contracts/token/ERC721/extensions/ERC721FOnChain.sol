// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24 <0.9.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../../interfaces/IERC4883.sol";
import "../../../utils/BytesBuilder.sol";
import "../ERC721F.sol";

/**
 * Extension of ERC721F which contains foundation for OnChain tokenURI generation
 */
abstract contract ERC721FOnChain is IERC4883, ERC721F {
    string private description;

    error NonExistingToken();

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner,
        string memory description_
    ) ERC721F(name_, symbol_, initialOwner) {
        description = description_;
    }

    /**
     * @notice Returns description of the contract
     */
    function getDescription() public view virtual returns (string memory) {
        return description;
    }

    /**
     * @notice Creates the tokenURI which contains the name, description, generated SVG image and token traits
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistingToken();
        string memory svgData = renderTokenById(tokenId);
        string memory traits = getTraits(tokenId);
        bytes memory nameBytes = bytes(name());
        bytes memory descriptionBytes = bytes(getDescription());
        bytes memory image = bytes(Base64.encode(bytes(svgData)));
        bytes memory traitBytes = bytes(traits);
        bytes memory separator =
            traitBytes.length == 0 ? bytes('"') : bytes('", "attributes": ');
        uint256 cap = 177 + nameBytes.length + descriptionBytes.length;
        cap += image.length + separator.length + traitBytes.length;
        (bytes memory out, uint256 ptr) = BytesBuilder.start(cap);
        ptr = BytesBuilder.w(
            ptr,
            bytes('data:application/json;utf-8,{"name": "')
        );
        ptr = BytesBuilder.w(ptr, nameBytes);
        ptr = BytesBuilder.w(ptr, bytes(" #"));
        ptr = BytesBuilder.wNum(ptr, tokenId);
        ptr = BytesBuilder.w(ptr, bytes('", "description": "'));
        ptr = BytesBuilder.w(ptr, descriptionBytes);
        ptr = BytesBuilder.w(
            ptr,
            bytes('", "image": "data:image/svg+xml;base64,')
        );
        ptr = BytesBuilder.w(ptr, image);
        ptr = BytesBuilder.w(ptr, separator);
        ptr = BytesBuilder.w(ptr, traitBytes);
        ptr = BytesBuilder.w1(ptr, 0x7d);
        BytesBuilder.finish(out, ptr);
        return string(out);
    }

    /**
     * @notice Generates the SVG image of the tokenId
     */
    function renderTokenById(
        uint256
    ) public view virtual returns (string memory) {}

    /**
     * @notice Returns the traits that are associated with `id`
     * @dev override and return "" to not have any traits in collection
     */
    function getTraits(uint256) public view virtual returns (string memory) {}
}
