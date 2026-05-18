# Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Running tests locally

### Hardhat

1. Copy .env.example and rename to .env
2. `nvm use`
3. `npm install`
4. `npx hardhat compile`
5. `npx hardhat test`

> **Warning**
> When running any test of a contract located in /examples, you'll receive a compilation error due to the @franknft.eth/erc721-f library not being installed.
> To prevent this error you must change all imports where @franknft.eth/erc721-f to the location of the local file. For example "../contracts/utils/AllowList.sol" in the AllowList example.

> **Warning**
> Since hardhat only compiles a single path at once, you'll probably fail every single test that's executed on solutions located in /examples. This is because those artifacts haven't been created yet.
> These can be created by changing the the sources path in hardhat.config.js to "./examples" and executing step 3 again.

**Note:** `npx hardhat clean` removes the created artifacts

#### Running a single test

`npx hardhat test ./test/token/ERC721/GasUsage.test.js`

#### Testing gas consumption

- Enable the creation of a gas report by setting `REPORT_GAS` to `true` in `.env`
- Toggle the creation of a gas report file by (un)commenting `outputFile` in `hardhat.config.js`
- Change the total runs and toggle the optimizer by changing the `solidity` `optimizer` values in `hardhat.config.js`

### Foundry

1. Install [Rust](https://www.rust-lang.org/tools/install)
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. `forge build`
4. `forge test`

#### Running a single test

`forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol`

#### Testing gas consumption

`forge test --gas-report`
