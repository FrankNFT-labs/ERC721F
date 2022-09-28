// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title ChainLink
 *
 * @dev Example implementation of [ERC721F] which supports random mint
 * based on https://docs.chain.link/docs/vrf/v2/examples/get-a-random-number/
 */
contract ChainLink is ERC721F, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 subscriptionId;

    // Respective values of goerli test network, find other networks keyHash/vrfCoordinator at https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000; // Add set method

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3; // Add set method

    // Single number is required for setting the startingIndex
    uint32 numWords = 1;

    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31;
    uint256 public startingIndex;
    bool public saleIsActive;

    event RequestedRandomness(uint256 requestId);

    constructor(uint64 _subscriptionId, address _vrfCoordinator)
        VRFConsumerBaseV2(_vrfCoordinator)
        ERC721F("ChainLink", "Chain")
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
    }

    function flipSaleState() external onlyOwner {
        if (!saleIsActive)
            require(
                startingIndex != 0,
                "startingIndex must be set before sale can begin"
            );
        saleIsActive = !saleIsActive;
    }

    function setRandomStartingIndex() external onlyOwner {
        require(startingIndex == 0, "startingIndex already set");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        
        emit RequestedRandomness(requestId);
    }

    function mint(uint32 numberOfTokens) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfTokens cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );

        uint256 supply = totalSupply();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );

        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, (startingIndex + supply + i) % MAX_TOKENS); // no need to use safeMint as we don't allow contracts.
            unchecked {
                i++;
            }
        }
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords)
        internal
        override
    {
        startingIndex = (randomWords[0] % MAX_TOKENS) + 1;
    }
}
