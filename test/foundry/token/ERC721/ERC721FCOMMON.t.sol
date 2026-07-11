// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/ERC721FCOMMONOwnerMock.sol";

/**
 * @title ERC721FCOMMONTest
 * @notice Regression suite for ERC721FCOMMON construction.
 *
 * Locks in that the contract can be deployed with an `initialOwner` that
 * differs from the deployer (OZ5 Ownable pattern). Previously the
 * constructor called the onlyOwner `setRoyaltyReceiver`, which reverted
 * with OwnableUnauthorizedAccount whenever deployer != initialOwner.
 */
contract ERC721FCOMMONTest is Test {
    address internal multisig;

    function setUp() public {
        multisig = makeAddr("multisig");
    }

    // ─── constructor — third-party initialOwner ──────────────────────────────

    function test_deploy_withThirdPartyInitialOwner() public {
        ERC721FCOMMONOwnerMock token = new ERC721FCOMMONOwnerMock(multisig);
        assertEq(token.owner(), multisig);
    }

    function test_deploy_setsRoyaltyReceiverToInitialOwner() public {
        ERC721FCOMMONOwnerMock token = new ERC721FCOMMONOwnerMock(multisig);
        token.mint(address(this), 0);
        (address receiver, uint256 royaltyAmount) = token.royaltyInfo(
            0,
            10_000
        );
        assertEq(receiver, multisig);
        assertEq(royaltyAmount, 500); // default royalty is 500 bp = 5%
    }

    // ─── constructor — deployer as initialOwner (regression guard) ───────────

    function test_deploy_withDeployerAsInitialOwner() public {
        ERC721FCOMMONOwnerMock token = new ERC721FCOMMONOwnerMock(
            address(this)
        );
        assertEq(token.owner(), address(this));
        token.mint(address(this), 0);
        (address receiver, ) = token.royaltyInfo(0, 10_000);
        assertEq(receiver, address(this));
    }
}
