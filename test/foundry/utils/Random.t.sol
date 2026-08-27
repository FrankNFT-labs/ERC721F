// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/RandomMock.sol";

/**
 * @title RandomTest
 * @notice Behavioral suite for Random.sol. True randomness is untestable;
 * these tests pin the entropy sources instead: the internal nonce, the
 * caller, the timestamp and the optional seed must each influence the
 * outcome, and identical state must reproduce identical values.
 */
contract RandomTest is Test {
    RandomMock internal randomMock;
    address internal alice;
    address internal bob;

    function setUp() public {
        randomMock = new RandomMock();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function test_random_consecutiveCallsDiffer() public {
        // Identical block and sender; only the internal nonce differs.
        uint256 first = randomMock.drawRandom();
        uint256 second = randomMock.drawRandom();
        assertTrue(first != second);
    }

    function test_random_deterministicForIdenticalState() public {
        RandomMock other = new RandomMock();
        assertEq(randomMock.drawRandom(), other.drawRandom());
    }

    function test_random_differsBetweenSenders() public {
        RandomMock other = new RandomMock();
        vm.prank(alice);
        uint256 aliceValue = randomMock.drawRandom();
        vm.prank(bob);
        uint256 bobValue = other.drawRandom();
        assertTrue(aliceValue != bobValue);
    }

    function test_random_timestampChangesOutcome() public {
        RandomMock other = new RandomMock();
        uint256 before = randomMock.drawRandom();
        vm.warp(block.timestamp + 100);
        uint256 later = other.drawRandom();
        assertTrue(before != later);
    }

    function test_randomWithSeed_deterministicForIdenticalSeed() public {
        RandomMock other = new RandomMock();
        assertEq(
            randomMock.drawRandomWithSeed(42),
            other.drawRandomWithSeed(42)
        );
    }

    function test_randomWithSeed_seedChangesOutcome() public {
        RandomMock other = new RandomMock();
        assertTrue(
            randomMock.drawRandomWithSeed(1) != other.drawRandomWithSeed(2)
        );
    }
}
