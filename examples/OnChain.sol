// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/extensions/ERC721FOnChain.sol";

/**
 * @title OnChain
 * 
 * @dev Example implementation of [ERC721FOnChain] with overridden functions for custom SVG and URI creation
 */
contract OnChain is ERC721FOnChain {
    string constant svgHead =
        '<svg viewBox="0 0 350 350" xmlns="http://www.w3.org/2000/svg"><style>.centered-text{text-anchor:middle;dominant-baseline:middle}</style><defs><linearGradient id="rainbow" x1="0" x2="0" y1="0" y2="100%" gradientUnits="userSpaceOnUse"><stop stop-color="#FF5B99" offset="0%"/><stop stop-color="#FF5447" offset="20%"/><stop stop-color="#FF7B21" offset="40%"/><stop stop-color="#EAFC37" offset="60%"/><stop stop-color="#4FCB6B" offset="80%"/><stop stop-color="#51F7FE" offset="100%"/></linearGradient></defs><rect width="100%" height="100%" rx="35"/><text fill="url(#rainbow)" class="centered-text"><tspan font-size="30" x="50%" y="30%">';
    string constant svgFooter = "</text></svg>";
    string[10] pokemon = ["Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon","Charizard","Squirtle","Wartortle","Blastoise", "Mew"];

    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31;
    bool public saleIsActive;

    constructor() ERC721FOnChain("OnChain", "OC", "Example OnChain Contract") {}

    /**
     * Changes the state of saleIsActive from true to false and false to true
     */
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * @notice Mints `numberOfTokens` tokens for `sender`
     */
    function mint(uint256 numberOfTokens)
        external
    {
        require(msg.sender==tx.origin,"No Contracts allowed.");
        require(saleIsActive,"Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(numberOfTokens < MAX_PURCHASE, "Can only mint 30 tokens at a time");
        uint256 supply = totalSupply();
        require(supply + numberOfTokens <= MAX_TOKENS, "Purchase would exceed max supply of Tokens");

        for(uint256 i; i < numberOfTokens;){
            _mint( msg.sender, supply + i ); // no need to use safeMint as we don't allow contracts.
            unchecked{ i++;}
        }
    }

    /**
     * @notice Overridden function to display description change in tokenURI
     */
    function getDescription() public view override returns (string memory) {
        return string(abi.encodePacked(description, " - Overwrote description"));
    }

    /**
     * @notice Overridden function which creates custom SVG image 
     * @dev `id` changes the displayed name in `parts[3]`, every 100th you get mew
     */
    function renderTokenById(uint256 id)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(id), "Non-Existing token");
        string[9] memory parts;
        parts[0] = svgHead;
        parts[1] = name();
        parts[2] = '</tspan><tspan font-size="65" x="50%" dy="20%">';
        parts[3] = id % 100 == 0 && id != 0 ? pokemon[9] : pokemon[id % (pokemon.length -1)];
        parts[4] = '</tspan><tspan font-size="20" x="50%" dy="15%">';
        parts[5] = getDescription();
        parts[
            6
        ] = '</tspan></text><path fill="transparent" stroke="gold" stroke-width="2" d="M338.971 322.5 300 345l-38.971-22.5v-45L300 255l38.971 22.5z"/><text font-size="15" fill="#fff" font-weight="bold" font-family="Cursive" x="300" y="300" class="centered-text">';
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

    /**
     * @notice Overridden function to show how to disable traits being included in the URI
     */
    function getTraits(uint256 /*id*/) public pure override returns (string memory) {
        return "";
    }
}