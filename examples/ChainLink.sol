// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

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
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000; // Add set method

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3; // Add set method

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1; // Add set method

    uint256[] public randomWords;
    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31;
    bool public saleIsActive;

    mapping(uint256 => address) requestToSender;

    event ReceivedRandomness(uint256 reqId, uint256[] randomWords);
    event RequestedRandomness(uint256 reqId, address invoker);

    constructor(uint64 _subscriptionId, address _vrfCoordinator)
        VRFConsumerBaseV2(_vrfCoordinator)
        ERC721F("ChainLink", "Chain")
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
    }

    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function mint(uint32 numberOfTokens) public returns (uint256 requestId) {
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        require(
            totalSupply() + 1 <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );

        require(
            numberOfTokens <= 500,
            "Can't request more words than internal limit set by ChainLink"
        );
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numberOfTokens
        );

        requestToSender[requestId] = msg.sender;
        emit RequestedRandomness(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory _randomWords
    ) internal override {
        randomWords = _randomWords;

        //address sender = requestToSender[requestId];
        //_mint(sender, _randomWords[0]);
        emit ReceivedRandomness(requestId, randomWords);
    }
}
