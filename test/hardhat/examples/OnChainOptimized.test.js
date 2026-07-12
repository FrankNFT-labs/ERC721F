import { expect } from "chai";
import { ethers, loadFixture } from "../helpers/connection.js";
const URI_PREFIX = "data:application/json;base64,";
const IMAGE_PREFIX = "data:image/svg+xml;base64,";

describe("OnChainOptimized", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("OnChainOptimized");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy();

        await hardhatToken.waitForDeployment();

        return { Token, hardhatToken, owner, addr1 };
    }

    async function deployTokenFixtureWithMint() {
        const fixture = await deployTokenFixture();
        await fixture.hardhatToken.flipSaleState();
        await fixture.hardhatToken.mint(1);
        return fixture;
    }

    describe("Minting", function () {
        it("Requires an active sale", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(1)).to.be.revertedWith(
                "Sale NOT active yet",
            );
        });

        it("Doesn't allow minting of zero tokens", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();

            await expect(hardhatToken.mint(0)).to.be.revertedWith(
                "numberOfNfts cannot be 0",
            );
        });

        it("Starts token ids at 1", async function () {
            const { hardhatToken, owner } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            expect(await hardhatToken.ownerOf(1)).to.equal(owner.address);
            expect(await hardhatToken.totalSupply()).to.equal(1);
        });

        it("Doesn't allow minting past MAX_TOKENS", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();
            await hardhatToken.mint(9);

            await expect(hardhatToken.mint(2)).to.be.revertedWith(
                "Purchase would exceed max supply of Tokens",
            );
        });

        it("Assigns an algorithmId trait seed per minted token", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();
            // 9 draws: the accumulator only stays 0 if every 5-bit draw is 0.
            await hardhatToken.mint(9);

            // Distinct algorithmIds cascade through lastSelected; the last
            // one assigned is exposed and must be set after minting.
            expect(await hardhatToken.lastSelected()).to.not.equal(0);
        });
    });

    describe("createRandomNumber", function () {
        it("Stays within the 5-bit trait space [0, 31]", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            for (let id = 0; id < 5; id++) {
                const value = await hardhatToken.createRandomNumber(id);
                expect(value).to.be.below(32);
            }
        });
    });

    describe("tokenURI", function () {
        it("Reverts for a non-existing token", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.tokenURI(1)).to.be.revertedWith(
                "Non-Existing token",
            );
        });

        it("Returns base64 JSON with name, image and the four traits", async function () {
            const { hardhatToken } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            const uri = await hardhatToken.tokenURI(1);
            expect(uri.startsWith(URI_PREFIX)).to.be.true;

            const json = JSON.parse(
                Buffer.from(
                    uri.substring(URI_PREFIX.length),
                    "base64",
                ).toString(),
            );
            expect(json.name).to.equal("BunniesSamplingOwnAlgorithm 1");
            expect(json.image.startsWith(IMAGE_PREFIX)).to.be.true;

            const traitTypes = json.attributes.map((a) => a.trait_type);
            expect(traitTypes).to.deep.equal([
                "Background",
                "Bracelet",
                "Glasses",
                "Purse",
            ]);
        });

        it("Embeds a well-formed SVG in the image field", async function () {
            const { hardhatToken } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            const uri = await hardhatToken.tokenURI(1);
            const json = JSON.parse(
                Buffer.from(
                    uri.substring(URI_PREFIX.length),
                    "base64",
                ).toString(),
            );
            const svg = Buffer.from(
                json.image.substring(IMAGE_PREFIX.length),
                "base64",
            ).toString();

            expect(svg.startsWith("<svg")).to.be.true;
            expect(svg.endsWith("</svg>")).to.be.true;
        });
    });
});
