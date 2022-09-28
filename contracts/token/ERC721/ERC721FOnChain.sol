// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "./ERC721F.sol";

contract ERC721FOnChain is ERC721F {
    string description;
    mapping(uint256 => string) data;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory description_
    ) ERC721F(name_, symbol_) {
        description = description_;
    }

    function getData(uint256 tokenId) external view returns (string memory) {
        return data[tokenId];
    }

    function getDescription() public view returns (string memory) {
        return description;
    }

    function mint(string calldata text, address to)
        external
        onlyOwner
        returns (uint256)
    {
        uint256 supply = totalSupply();
        _safeMint(to, supply);
        data[supply] = text;
        return supply;
    }

    function getSvg(uint tokenId) private view returns (string memory) {
        string[5] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = name();
        parts[2] = getDescription();
        parts[3] = data[tokenId];
        parts[4] = "</text></svg>";
        return
            string(
                abi.encodePacked(
                    parts[0],
                    parts[1],
                    "  ",
                    parts[2],
                    " ",
                    parts[3],
                    parts[4]
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Non-Existing token");
        string memory svgData = getSvg(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name(), " ", 
                        Strings.toString(tokenId),
                        '", "description": "', getDescription(), '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svgData)),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
