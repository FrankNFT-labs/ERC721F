cls
forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --match-test \W*(testMint)\W* --gas-report > forge-snapshots/mint.gas-snapshot
forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --match-test \W*(TransferMintOne)\W* --gas-report > forge-snapshots/mint-1-Transfer.gas-snapshot
forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --match-test \W*(TransferMintTen)\W* --gas-report > forge-snapshots/mint-10-Transfer.gas-snapshot
forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --match-test \W*(TransferMintHundred)\W* --gas-report > forge-snapshots/mint-100-Transfer.gas-snapshot