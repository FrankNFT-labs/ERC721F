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

> **Note**
> Contracts in /examples import the published `@franknft.eth/erc721-f` package. Before compiling or testing them locally, run `npm run update-example-imports:dev` to rewrite those imports to local paths (CI does the same in both jobs); `npm run update-example-imports:prod` restores the published form. The pre-commit hook keeps committed files in the published form.
> The root Hardhat config compiles `contracts/` and `examples/` together in one run, so no config changes are needed.

**Note:** `npx hardhat clean` removes the created artifacts

#### Running a single test

`npx hardhat test ./test/hardhat/token/ERC721/GasUsage.test.js`

#### Testing gas consumption

- Generate a gas report with Hardhat 3's built-in flag: `npx hardhat test --gas-stats`
- Write the report to a JSON file with `npx hardhat test --gas-stats-json <path>`
- Change the total runs and toggle the optimizer by changing the `optimizer` values under `solidity.profiles.default.settings` in `hardhat.config.js`

### Foundry

1. Install [Rust](https://www.rust-lang.org/tools/install)
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. `forge build`
4. `forge test`

#### Running a single test

`forge test --match-path test/foundry/token/ERC721/ERC721FGasReporterMock.t.sol`

#### Testing gas consumption

`forge test --gas-report`
