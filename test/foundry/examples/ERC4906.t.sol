// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../examples/mocks/ERC4906Mock.sol";
import "../../../lib/forge-std/src/Test.sol";

/**
 * @title ERC4906Test
 *
 * @dev Contract utilised to test additional contractfunctionality and retained functionality of overridden functions
 */
contract ERC4906Test is Test {
    ERC4906Mock private t;
    address private owner;
    string private constant TOKEN_URI = "uri";

    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    function setUp() public {
        t = new ERC4906Mock();
        t.flipSaleState();
        owner = t.owner();
        vm.startPrank(owner, owner);
    }

    function testSupportsInterfaceReturnsRequiredTrue() public {
        assertTrue(t.supportsInterface(0x49064906));
    }

    function testTokenURIReturnsSetValue() public {
        t.mint(1, TOKEN_URI);
        assertEq(t.tokenURI(0), TOKEN_URI);
    }

    function testSetTokenURIEmitsMetaDataUpdateEvent() public {
        t.mint(1, TOKEN_URI);
        vm.expectEmit(false, false, false, true);
        emit MetadataUpdate(0);
        t.setTokenURI(0, "newURI");
    }

    function testSetTokenURISEmitsBatchMetaDataUpdateEvent() public {
        uint256 _fromTokenId = 0;
        uint256 _toTokenId = 10;
        t.mint(11, TOKEN_URI);
        vm.expectEmit(false, false, false, true);
        emit BatchMetadataUpdate(_fromTokenId, _toTokenId);
        t.setTokenURIS(_fromTokenId, _toTokenId, "newURI");
    }

    function testSetBaseTokenURIAffectsTokenURI() public {
        string memory baseURI = "Prefix";
        t.mint(1, TOKEN_URI);
        t.setBaseTokenURI(baseURI);
        assertEq(t.tokenURI(0), string(abi.encodePacked(baseURI, TOKEN_URI)));
    }

    function testBurnIncreasesBurnCounter() public {
        t.mint(1, TOKEN_URI);
        assertEq(t.totalBurned(), 0);
        t.burn(0);
        assertEq(t.totalBurned(), 1);
    }
}
