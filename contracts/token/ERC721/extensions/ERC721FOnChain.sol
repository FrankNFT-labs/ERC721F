// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../../interfaces/IERC4883.sol";
import "../ERC721F.sol";

abstract contract ERC721FOnChain is IERC4883, ERC721F {
    string description;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory description_
    ) ERC721F(name_, symbol_) {
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
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Non-Existing token");
        string memory svgData = renderTokenById(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name(),
                        " ",
                        Strings.toString(tokenId),
                        '", "description": "',
                        getDescription(),
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svgData)),
                        '", "attributes": ',
                        getTraits(tokenId),
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /**
     * @notice Generates the SVG image of the tokenId
     * @dev Image contains the name, description, text linked to the token and `id`
     */
    function renderTokenById(uint256 id)
        public
        view
        virtual
        returns (string memory)
    {
        require(_exists(id), "Non-Existing token");
        string[4] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = name();
        parts[2] = getDescription();
        parts[3] = '</text></svg>';
        return
            string(
                abi.encodePacked(
                    parts[0],
                    parts[1],
                    parts[2],
                    parts[3]
                )
            );
    }

    /**
     * @notice Returns the traits that are associated with `id`
     * @dev Creates one static and one dynamic trait
     */
    function getTraits(uint256 id) public view virtual returns (string memory) {
        require(_exists(id), "Non-Existing token");
        string[2] memory traits;
        traits[0] = string(
            abi.encodePacked(
                "{"
                "\n",
                '"trait_type": "TypeName",',
                "\n",
                '"value": "',
                "testValue",
                '"',
                "\n",
                "}"
                "\n"
            )
        );
        traits[1] = string(
            abi.encodePacked(
                ",{",
                "\n",
                '"trait_type": "Id",',
                "\n",
                '"value": "',
                Strings.toString(id),
                '"',
                "\n",
                "}"
                "\n"
            )
        );
        return string(abi.encodePacked("[", traits[0], traits[1], "]"));
    }
}
