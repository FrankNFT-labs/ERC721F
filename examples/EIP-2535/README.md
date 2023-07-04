[![MIT License][license-shield]][license-url]

# EIP-2535

Example contract on how to use the Diamond Standard (EIP-2535) to setup a contract using ERC721F

The Author is not liable for any outcomes as a result of using EIP-2535. **DYOR!**

## Usage

Hardhat commands such as npx hardhat test will only function while being in the examples/EIP-2535 folder.

Alternatively the scripts written in the package.json located in the same folder can be executed from the root of the project using npm run as following.

```
npm run [script] --workspace=eip-2535 //npm run test --workspace=eip-2535
```

> **Warning**
> The test files located within the examples/EIP-2535 folder will only have access to the artifacts in that folder, artifacts located in the root of the project can't be accessed

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge
[license-url]: https://github.com/FrankNFT-labs/ERC721F/blob/main/LICENSE
