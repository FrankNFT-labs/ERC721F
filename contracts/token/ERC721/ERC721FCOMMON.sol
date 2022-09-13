// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "./ERC721F.sol";
import "./extensions/ERC721Payable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/token/common/ERC2981.sol";

contract ERC721FCOMMON is ERC721F, ERC721Payable, ERC2981 {
    uint16 private royalties = 500;

    event RoyaltiesUpdated(uint256 royalties);

    constructor(string memory name_, string memory symbol_) ERC721F(name_, symbol_) {
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return
            _interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    function setRoyalties(uint16 _royalties) external onlyOwner {
        require(
            _royalties != 0 && _royalties < 90,
            "royalties should be between 0 and 90"
        );

        royalties = (_royalties * 100);

        emit RoyaltiesUpdated(_royalties);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        require(
            _exists(_tokenId),
            "ERC2981RoyaltyStandard: Royalty info for nonexistent token"
        );
        return (address(this), (_salePrice * royalties) / 10000);
    }
}