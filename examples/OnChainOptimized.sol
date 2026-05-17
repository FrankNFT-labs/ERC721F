// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@franknft.eth/erc721-f/contracts/interfaces/IERC4883.sol";
import "@franknft.eth/erc721-f/contracts/token/ERC721/ERC721F.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title OnChainOptimized
 * @notice Example NFT collection (bunnies) with all metadata generated fully on-chain.
 *         Demonstrates how to pack multiple discrete traits into a single `uint256`
 *         using bitfield encoding, avoiding per-trait storage slots.
 *
 * @dev Trait layout — the collection has four trait categories:
 *
 *  | Trait      | Options | Bits needed | Bit positions in algorithmId |
 *  |------------|---------|-------------|------------------------------|
 *  | Glasses    |    4    |      2      | bits 0, 2                    |
 *  | Purse      |    4    |      2      | bits 1, 4                    |
 *  | Bracelet   |    2    |      1      | bit  3                       |
 *  | Background |    6    |     n/a     | not in bitfield (modulo)     |
 *
 *  Total bitfield combinations: 4 × 4 × 2 = 32 → fits in 5 bits (values 0–31).
 *  Background is distributed separately via `id % 6` so all 6 colours appear
 *  uniformly across the 32 algorithmId values without consuming extra bits.
 *
 *  The entire trait set for a token is stored as a single `uint256 algorithmId`
 *  in `idToAlgorithmId[tokenId]`.  A single SSTORE per mint covers all traits.
 *  The alternative — one mapping per trait — would cost 4 SSTOREs per mint.
 *
 * @author @FrankNFT.eth
 */
contract OnChainOptimized is IERC4883, ERC721F {
    uint256 public constant MAX_TOKENS = 10;
    uint256 public constant MAX_PURCHASE = 10;
    uint256 public lastSelected = 0; // Accumulator: tracks the last algorithmId assigned; seeds next random draw.
    bool public saleIsActive;
    /**
     * @dev Maps each tokenId to its packed `algorithmId` (a 5-bit value, 0–31).
     *      All four traits (glasses, purse, bracelet, background) are derived from
     *      this single stored integer via bit extraction — no per-trait mappings needed.
     *      One SSTORE per mint vs four if each trait were stored separately.
     */
    mapping(uint256 => uint256) private idToAlgorithmId;

    error ContractsNotAllowed();

    constructor() ERC721F("BunniesSamplingOwnAlgorithm", "OC", msg.sender) {}

    /**
     * Changes the state of saleIsActive from true to false and false to true
     */
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * @notice Mints `numberOfTokens` tokens for `sender`.
     *
     * @dev Trait assignment uses a **running accumulator + random offset** pattern:
     *
     *      `algorithmId = lastSelected + createRandomNumber(tokenId)`
     *
     *      Adding the previous token's algorithmId as an offset prevents two tokens
     *      minted in the same block from receiving identical traits even when
     *      `block.timestamp` and `block.prevrandao` are identical (same block).
     *      `lastSelected` is then updated to the new algorithmId, so each mint
     *      cascades into the next.
     *
     *      The result is stored in `idToAlgorithmId[tokenId]` — a single SSTORE that
     *      encodes all three bitfield traits (glasses, purse, bracelet) at once.
     */
    function mint(uint256 numberOfTokens) external {
        if (msg.sender.code.length != 0) revert ContractsNotAllowed();
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 9 tokens at a time"
        );
        uint256 supply = totalSupply(); // number of tokens minted so far (used to derive next tokenId)
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        unchecked {
            while (numberOfTokens != 0) {
                uint256 tokenId = supply + 1;
                uint256 algorithmId = lastSelected +
                    createRandomNumber(tokenId);
                _mint(msg.sender, tokenId);
                idToAlgorithmId[tokenId] = algorithmId;
                lastSelected = algorithmId;
                supply++;
                numberOfTokens--;
            }
        }
    }

    /**
     * @notice Creates the tokenURI which contains the name, description, generated SVG image and token traits
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "Non-Existing token");
        string memory svgData = renderTokenById(tokenId);
        string memory traits = getTraits(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name(),
                        " ",
                        Strings.toString(tokenId),
                        '", "description": "',
                        getDescription(),
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svgData)),
                        bytes(traits).length == 0 ? '"' : '", "attributes": ',
                        traits,
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /**
     * @notice Generates a pseudo-random number in [0, 31] used as the trait seed.
     *
     * @dev The modulus 32 (= 2^5) matches the 5-bit bitfield:
     *      4 purses × 4 glasses × 2 bracelets = 32 possible trait combinations.
     *      `% 32` therefore maps evenly onto every valid algorithmId without waste.
     *
     *      Entropy sources mixed via keccak256:
     *      - `block.timestamp`  — changes each block, varies between transactions
     *      - `block.prevrandao` — RANDAO beacon value from the previous block (EVM Cancun)
     *      - `tokenId`          — unique per token, prevents collisions within a batch
     *      - `msg.sender`       — caller address, differs between wallets
     *
     * @dev WARNING: This is not cryptographically secure randomness.  A validator
     *      can influence `prevrandao` at some cost.  For a production collection
     *      with high-value traits, use Chainlink VRF (see `examples/ChainLink.sol`).
     */
    function createRandomNumber(uint256 tokenId) public view returns (uint256) {
        unchecked {
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        tokenId,
                        msg.sender
                    )
                )
            ) % 32;
            return random;
        }
    }

    /**
     * @notice Overridden function which creates custom SVG image
     * @dev `id` changes the displayed name in `parts[3]`, every 100th you get mew
     */
    function renderTokenById(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "Non-Existing token");
        //header1, header2, body, rest, footer
        string[5] memory frame = [
            '<svg width="1080" height="1080"',
            '" stroke="#000" xmlns="http://www.w3.org/2000/svg">',
            '<ellipse stroke-width="10" ry="266" rx="200" cy="540" cx="540" fill="#fff"/>',
            '<ellipse transform="rotate(25 660 250)" ry="107" rx="45" cy="250" cx="660" stroke-width="10" fill="#fff"/><ellipse transform="rotate(-25 420 250)" ry="107" rx="45" cy="250" cx="420" stroke-width="10" fill="#fff"/><ellipse transform="rotate(-25 435 283)" ry="68" rx="26" cy="283" cx="435" stroke-width="10" fill="#FFAFCC"/><ellipse transform="rotate(25 645 283)" ry="68" rx="26" cy="283" cx="645" stroke-width="10" fill="#FFAFCC"/><circle cy="427" cx="470" stroke-width="10" r="30"/><circle cy="427" cx="610" stroke-width="10" r="30"/><circle cy="418" cx="465" r="12" fill="#fff" stroke="none"/><circle cy="440" cx="484" r="6" fill="#fff" stroke="none"/><circle cy="418" cx="615" r="12" fill="#fff" stroke="none"/><circle cy="440" cx="600" r="8" fill="#fff" stroke="none"/><circle cy="520" cx="540" stroke-width="4" fill="#FFAFCC" r="14"/><ellipse ry="120" rx="100" cy="685" cx="540" stroke-width="4" fill="#FFE2FF"/><ellipse ry="106" rx="80" cy="697" cx="540" fill="#FFAFCC" stroke="none"/><ellipse transform="rotate(-17 610 804)" ry="43" rx="30" cy="804" cx="610" stroke-width="10" fill="#fff"/><ellipse transform="rotate(17 470 804)" ry="43" rx="30" cy="804" cx="470" stroke-width="10" fill="#fff"/><ellipse transform="rotate(30 750 518)" ry="48" rx="31" cy="518" cx="750" stroke-width="10" fill="#fff"/><ellipse transform="rotate(-30 330 518)" ry="48" rx="31" cy="518" cx="330" stroke-width="10" fill="#fff"/>',
            "</svg>"
        ];

        uint256 algorithmId = idToAlgorithmId[tokenId];
        string memory output = string(
            abi.encodePacked(
                frame[0],
                getBackground(getBackgroundId(algorithmId)),
                frame[1],
                frame[2],
                getGlasses(getGlassesId(algorithmId))
            )
        );
        output = string(
            abi.encodePacked(
                output,
                frame[3],
                getBracelet(getBraceletId(algorithmId)),
                getPurse(getPurseId(algorithmId)),
                frame[4]
            )
        );
        return string(output);
    }

    /**
     * @notice Overridden function to show how to disable traits being included in the URI
     * Optional: with mapping int to text
     * Lot of extra work because recreate bunnie
     * Does not print out integer
     */
    function getTraits(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Non-Existing token");
        string memory tr1 = '[{"trait_type": "Background","value": "';
        string memory tr2 = '"},{"trait_type": "Bracelet","value": "';
        string memory tr3 = '"},{"trait_type": "Glasses","value": "';
        string memory tr4 = '"},{"trait_type": "Purse","value": "';
        string memory tr5 = '"}]';
        uint256 algorithmId = idToAlgorithmId[tokenId];
        string memory o = string(
            abi.encodePacked(
                tr1,
                Strings.toString(getBackgroundId(algorithmId)),
                tr2,
                Strings.toString(getBraceletId(algorithmId)),
                tr3,
                Strings.toString(getGlassesId(algorithmId))
            )
        );
        return
            string(
                abi.encodePacked(
                    o,
                    tr4,
                    Strings.toString(getPurseId(algorithmId)),
                    tr5
                )
            );
    }

    /**
     * @notice Overridden function to display description change in tokenURI
     */
    function getDescription() public pure returns (string memory) {
        return string(abi.encodePacked(" - Overwrote description"));
    }

    /**
     * @notice Returns the background colour index for a given `algorithmId`.
     *
     * @dev Background is NOT encoded in the bitfield.  The 5 bitfield bits are fully
     *      consumed by glasses (2 bits), purse (2 bits), and bracelet (1 bit).
     *      Adding a 6th background option would require a 3-bit slot (8 values) but
     *      there are only 6 backgrounds — wasteful.
     *
     *      Instead, background is derived with `id % 6`, which distributes evenly
     *      across all 32 bitfield values (32 = 5 × 6 + 2, so IDs 0 and 1 appear once
     *      more than the rest — a tiny bias that is acceptable for an example).
     *
     *      This keeps the per-trait bit positions clean and avoids gaps.
     */
    function getBackgroundId(
        uint256 id
    ) public pure returns (uint256 backgroundId) {
        return id % 6;
    }

    /**
     * @notice Extracts the purse variant (0–3) from the packed `algorithmId`.
     *
     * @dev Purse uses bits 1 and 4 of the algorithmId (0-indexed from LSB):
     *
     *      bit1 = (id >> 1) & 1  →  bit at position 1
     *      bit2 = (id >> 4) & 1  →  bit at position 4
     *      purseId = (bit2 << 1) | bit1  →  recombined as a 2-bit value [0, 3]
     *
     *      The two bits are non-adjacent so they do not overlap with glasses (bits 0, 2)
     *      or bracelet (bit 3).  Every bit in positions 0–4 is used by exactly one trait.
     */
    function getPurseId(uint256 id) public pure returns (uint256 purseId) {
        uint256 bit1 = (id >> 1) & 1;
        uint256 bit2 = (id >> 4) & 1;
        return ((bit2 << 1) | bit1);
    }

    /**
     * @notice Extracts the bracelet variant (0 or 1) from the packed `algorithmId`.
     *
     * @dev Bracelet occupies bit 3 only — a single-bit extract:
     *
     *      braceletId = (id >> 3) & 1  →  0 or 1
     *
     *      Two bracelet colours map to these values in `getBracelet()`.
     */
    function getBraceletId(
        uint256 id
    ) public pure returns (uint256 braceletId) {
        uint256 bit1 = (id >> 3) & 1;
        return bit1;
    }

    /**
     * @notice Extracts the glasses variant (0–3) from the packed `algorithmId`.
     *
     * @dev Glasses uses bits 0 and 2 of the algorithmId:
     *
     *      bit1 = id & 1          →  bit at position 0 (LSB)
     *      bit2 = (id >> 2) & 1   →  bit at position 2
     *      glassesId = (bit2 << 1) | bit1  →  recombined as a 2-bit value [0, 3]
     *
     *      Bit 1 is skipped here because it belongs to purse, so glasses bits
     *      are positions 0 and 2 (non-contiguous).
     */
    function getGlassesId(uint256 id) public pure returns (uint256 glassesId) {
        uint256 bit1 = id & 1;
        uint256 bit2 = (id >> 2) & 1;
        return ((bit2 << 1) | bit1);
    }

    /**
     * 2 colors represent the bracelets
     */
    function getBracelet(
        uint256 braceletId
    ) public pure returns (string memory) {
        string[2] memory braceletColors = ["FFF093", "05faf6"];
        string[2] memory bracelet = [
            '<circle cy="520" cx="310" r="8" fill="#FFF093" stroke-width="4"/><circle cy="510" cx="350" r="8" fill="#FFF093" stroke-width="4"/><circle cy="519" cx="331" r="12" fill="#',
            '       " stroke-width="4"/>'
        ];
        return
            string(
                abi.encodePacked(
                    bracelet[0],
                    braceletColors[braceletId % 2],
                    bracelet[1]
                )
            );
    }

    function getPurse(uint256 purseId) public pure returns (string memory) {
        string[2] memory upperPartPurse = [
            '<circle cy="580" cx="330" r="60" stroke="none"/><circle cy="580" cx="330" r="40" fill="#fff" stroke="none"/>',
            '<rect y="530" x="280" width="100" height="120" stroke-width="8"/><rect y="530" x="290" width="80" height="100" stroke-width="8" fill="#fff"/>'
        ];
        string
            memory lowerPartPurse = '<rect y="580" x="240" width="180" height="120" stroke-width="8" ';
        string[4] memory designPurse = [
            'fill="#f73149"/><rect y="600" x="260" width="140" height="80" stroke-width="8" fill="#f58822"/><rect y="620" x="280" width="100" height="40" stroke-width="8" fill="#f5c43d"/>',
            'fill="#9F87FB"/><rect y="650" x="310" width="30" height="30" stroke-width="8" fill="#e06cf5"/><rect y="590" x="350" width="30" height="30" stroke-width="8" fill="#e06cf5"/><rect y="640" x="380" width="30" height="30" stroke-width="8" fill="#e06cf5"/><rect y="610" x="260" width="30" height="30" stroke-width="8" fill="#e06cf5"/>',
            '<rect y="550" x="240" width="180" height="30" stroke-width="8" fill="#9efa84"/><rect y="580" x="240" width="180" height="30" stroke-width="8" fill="#7ac9fa"/><rect y="610" x="240" width="180" height="30" stroke-width="8" fill="#b67afa"/><rect y="640" x="240" width="180" height="30" stroke-width="8" fill="#ea72f7"/>',
            '<rect y="560" x="240" width="45" height="120" stroke-width="8" fill="#9efa84"/><rect y="560" x="285" width="45" height="120" stroke-width="8" fill="#7ac9fa"/><rect y="560" x="330" width="45" height="120" stroke-width="8" fill="#b67afa"/><rect y="560" x="375" width="45" height="120" stroke-width="8" fill="#ea72f7"/>'
        ];

        if (purseId == 0) {
            return string(abi.encodePacked(upperPartPurse[1], designPurse[3]));
        } else if (purseId == 1) {
            return string(abi.encodePacked(upperPartPurse[1], designPurse[2]));
        } else {
            return
                string(
                    abi.encodePacked(
                        upperPartPurse[0],
                        lowerPartPurse,
                        designPurse[purseId - 2]
                    )
                );
        }
    }

    function getGlasses(uint256 glassesId) public pure returns (string memory) {
        string[4] memory glassesColors = [
            "ed4949",
            "ffff56",
            "ff7f00",
            "00bf00"
        ];
        string[4] memory bigGlasses = [
            '<path stroke-width="4" fill="#',
            '" d="M492 417h140v20H492z"/><circle cy="427" cx="470" stroke-width="4" r="55" fill="#',
            '"/><circle cy="427" cx="470" stroke-width="4" r="45" fill="#fff"/><circle cy="427" cx="610" stroke-width="4" r="55" fill="#',
            '"/><circle cy="427" cx="610" stroke-width="4" r="45" fill="#fff"/>'
        ];

        string memory output;
        output = string(
            abi.encodePacked(
                bigGlasses[0],
                glassesColors[glassesId % 2],
                bigGlasses[1]
            )
        );

        return
            string(
                abi.encodePacked(
                    output,
                    glassesColors[glassesId % 4],
                    bigGlasses[2],
                    glassesColors[glassesId % 4],
                    bigGlasses[3]
                )
            );
    }

    /**
     * 6 background colors
     */
    function getBackground(uint256 id) public pure returns (string memory) {
        string[6] memory colors = [
            "CEC9DF",
            "FDF1CA",
            "EDCCB6",
            "B2C6DE",
            "E1E1E1",
            "C8DCB8"
        ];
        //return '';
        return
            string(
                abi.encodePacked(' style=" background-color:#', colors[id % 6])
            );
    }
}
