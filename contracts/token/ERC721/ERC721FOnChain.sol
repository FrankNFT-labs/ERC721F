// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721F.sol";
import "../../interfaces/IERC4883.sol";

contract ERC721FOnChain is ERC721F, IERC4883 {
    string constant svgHead = '<svg viewBox="0 0 350 350"><style>.centered-text{text-anchor:middle;dominant-baseline:middle}</style><defs><linearGradient id="rainbow" x1="0" x2="0" y1="0" y2="100%" gradientUnits="userSpaceOnUse"><stop stop-color="#FF5B99" offset="0%"/><stop stop-color="#FF5447" offset="20%"/><stop stop-color="#FF7B21" offset="40%"/><stop stop-color="#EAFC37" offset="60%"/><stop stop-color="#4FCB6B" offset="80%"/><stop stop-color="#51F7FE" offset="100%"/></linearGradient></defs><rect width="100%" height="100%" rx="35"/><text fill="url(#rainbow)" class="centered-text"><tspan font-size="30" x="50%" y="30%">';
    string constant svgFooter = '</text></svg>';
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

    function getDescription() public virtual view returns (string memory) {
        return description;
    }

    function mint(string calldata text, address to)
        external
        virtual
        onlyOwner
        returns (uint256)
    {
        uint256 supply = totalSupply();
        _safeMint(to, supply);
        data[supply] = text;
        return supply;
    }

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

    function renderTokenById(uint256 id) public virtual view returns (string memory) {
        require(_exists(id), "Non-Existing token");
        string[9] memory parts;
        parts[0] = svgHead;
        parts[1] = name();
        parts[2] = '</tspan><tspan font-size="65" x="50%" dy="20%">';
        parts[3] = data[id];
        parts[4] = '</tspan><tspan font-size="20" x="50%" dy="15%">';
        parts[5] = getDescription();
        parts[6] = '</tspan></text><path fill="transparent" stroke="gold" stroke-width="2" d="M338.971 322.5 300 345l-38.971-22.5v-45L300 255l38.971 22.5z"/><text font-size="15" fill="#fff" font-weight="bold" font-family="Cursive" x="300" y="300" class="centered-text">';
        parts[7] = Strings.toString(id);
        parts[8] = svgFooter;
        return
            string(
                abi.encodePacked(
                    parts[0],
                    parts[1],
                    parts[2],
                    parts[3],
                    parts[4],
                    parts[5],
                    parts[6],
                    parts[7],
                    parts[8]
                )
            );
    }
}
