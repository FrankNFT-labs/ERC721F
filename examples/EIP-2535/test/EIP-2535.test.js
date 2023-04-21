const { deployments } = require("hardhat");

describe("Token", () => {
  it("testing 1 2 3", async function () {
    await deployments.fixture(["EIP-2535"]);
    const Token = await deployments.get("EIP-2535"); // Token is available because the fixture was executed
    console.log(Token.address);
    // const ERC721BidSale = await deployments.get("ERC721BidSale");
    // console.log({ ERC721BidSale });
  });
});
