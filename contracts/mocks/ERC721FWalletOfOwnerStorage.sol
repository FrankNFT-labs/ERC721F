// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/extensions/ERC721FWalletOfOwnerStorage.sol";

contract ERC721FWalletOfOwnerStorageMock is ERC721FWalletOfOwnerStorage {
    constructor(string memory name, string memory symbol) ERC721F(name, symbol) {
        setBaseTokenURI("ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"); 
    }

    function mint(uint256 numberOfTokens) public {
        for(uint256 i; i < numberOfTokens;){
            _mint( msg.sender, totalSupply()); // no need to use safeMint as we don't allow contracts.
            unchecked{ i++;}
        }
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}