// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../../lib/forge-std/src/Test.sol";
import "../../../../../contracts/mocks/ERC721FOnChainMock.sol";

/**
 * @title ERC721FOnChainTest
 * @notice Behavioral suite for ERC721FOnChain.sol. The mock returns
 * deterministic SVG/trait strings, so the exact tokenURI composition can be
 * asserted for both the with-attributes and the no-attributes branch.
 *
 * NOTE: the current `data:application/json;utf-8,` prefix with raw
 * (unescaped) JSON is a known spec-compliance issue (review finding A2,
 * deliberately deferred). These tests pin today's behavior; adjust them
 * together with the A2 fix.
 */
contract ERC721FOnChainTest is Test {
    ERC721FOnChainMock internal onChain;
    address internal alice;

    string internal constant DESCRIPTION = "A test description";

    function setUp() public {
        onChain = new ERC721FOnChainMock("OnChainToken", "OCT", DESCRIPTION);
        alice = makeAddr("alice");
        onChain.mint(alice, 0);
    }

    function test_getDescription_returnsConstructorValue() public {
        assertEq(onChain.getDescription(), DESCRIPTION);
    }

    function test_tokenURI_revertsForNonexistentToken() public {
        vm.expectRevert(ERC721FOnChain.NonExistingToken.selector);
        onChain.tokenURI(1);
    }

    function test_tokenURI_composesJsonWithAttributes() public {
        string memory expected = string(
            abi.encodePacked(
                'data:application/json;utf-8,{"name": "OnChainToken #0", ',
                '"description": "',
                DESCRIPTION,
                '", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes("<svg>0</svg>")),
                '", "attributes": [{"trait_type": "Id", "value": "0"}]}'
            )
        );
        assertEq(onChain.tokenURI(0), expected);
    }

    function test_tokenURI_omitsAttributesWhenTraitsEmpty() public {
        onChain.setHasTraits(false);
        string memory expected = string(
            abi.encodePacked(
                'data:application/json;utf-8,{"name": "OnChainToken #0", ',
                '"description": "',
                DESCRIPTION,
                '", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes("<svg>0</svg>")),
                '"}'
            )
        );
        assertEq(onChain.tokenURI(0), expected);
    }

    function test_tokenURI_usesTokenSpecificSvgAndTraits() public {
        onChain.mint(alice, 12);
        string memory expected = string(
            abi.encodePacked(
                'data:application/json;utf-8,{"name": "OnChainToken #12", ',
                '"description": "',
                DESCRIPTION,
                '", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes("<svg>12</svg>")),
                '", "attributes": [{"trait_type": "Id", "value": "12"}]}'
            )
        );
        assertEq(onChain.tokenURI(12), expected);
    }
}
