import { expect } from "chai";
import { ethers, loadFixture } from "../helpers/connection.js";
const URI_PREFIX = "data:application/json;utf-8,";
const IMAGE_PREFIX = "data:image/svg+xml;base64,";

describe("OnChain", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("OnChain");
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

    describe("Deployment", function () {
        it("Supports ERC721 standards", async function () {
            const ERC721InterfaceId = "0x80ac58cd";
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.supportsInterface(ERC721InterfaceId)).to
                .be.true;
        });

        it("Overrides the description of the collection", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.getDescription()).to.equal(
                "Example OnChain Contract - Overwrote description",
            );
        });
    });

    describe("Minting", function () {
        it("Requires an active sale", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(1)).to.be.revertedWith(
                "Sale NOT active yet",
            );
        });

        it("Only allows the owner to flip the sale state", async function () {
            const { hardhatToken, addr1 } =
                await loadFixture(deployTokenFixture);

            await expect(
                hardhatToken.connect(addr1).flipSaleState(),
            ).to.be.revertedWithCustomError(
                hardhatToken,
                "OwnableUnauthorizedAccount",
            );
        });

        it("Doesn't allow minting of zero tokens", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();

            await expect(hardhatToken.mint(0)).to.be.revertedWith(
                "numberOfNfts cannot be 0",
            );
        });

        it("Doesn't allow minting more than MAX_PURCHASE - 1 tokens", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();

            await expect(hardhatToken.mint(31)).to.be.revertedWith(
                "Can only mint 30 tokens at a time",
            );
        });

        it("Assigns minted tokens to the sender", async function () {
            const { hardhatToken, owner } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            expect(await hardhatToken.ownerOf(0)).to.equal(owner.address);
            expect(await hardhatToken.totalSupply()).to.equal(1);
        });
    });

    describe("tokenURI", function () {
        it("Reverts for a non-existing token", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(
                hardhatToken.tokenURI(0),
            ).to.be.revertedWithCustomError(hardhatToken, "NonExistingToken");
        });

        it("Returns a utf-8 JSON data URI with name, description and image", async function () {
            const { hardhatToken } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            const uri = await hardhatToken.tokenURI(0);
            expect(uri.startsWith(URI_PREFIX)).to.be.true;

            const json = JSON.parse(uri.substring(URI_PREFIX.length));
            expect(json.name).to.equal("OnChain #0");
            expect(json.description).to.equal(
                "Example OnChain Contract - Overwrote description",
            );
            expect(json.image.startsWith(IMAGE_PREFIX)).to.be.true;
        });

        it("Embeds the rendered SVG as base64 in the image field", async function () {
            const { hardhatToken } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            const uri = await hardhatToken.tokenURI(0);
            const json = JSON.parse(uri.substring(URI_PREFIX.length));
            const svg = Buffer.from(
                json.image.substring(IMAGE_PREFIX.length),
                "base64",
            ).toString();

            expect(svg.startsWith("<svg")).to.be.true;
            expect(svg).to.contain("Bulbasaur"); // pokemon[0] for tokenId 0
            expect(svg.endsWith("</svg>")).to.be.true;
        });

        it("Contains the static and dynamic traits", async function () {
            const { hardhatToken } = await loadFixture(
                deployTokenFixtureWithMint,
            );

            const uri = await hardhatToken.tokenURI(0);
            const json = JSON.parse(uri.substring(URI_PREFIX.length));

            expect(json.attributes).to.have.lengthOf(2);
            expect(json.attributes[0].trait_type).to.equal("TypeName");
            expect(json.attributes[0].value).to.equal("testValue");
            expect(json.attributes[1].trait_type).to.equal("Id");
            expect(json.attributes[1].value).to.equal("0");
        });
    });

    describe("renderTokenById/getTraits", function () {
        it("Reverts for a non-existing token", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.renderTokenById(0)).to.be.revertedWith(
                "Non-Existing token",
            );
            await expect(hardhatToken.getTraits(0)).to.be.revertedWith(
                "Non-Existing token",
            );
        });
    });
});
