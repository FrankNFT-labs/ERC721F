@echo off
forge snapshot --asc --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --snap forge-snapshots/mint.gas-snapshot --match-test \W*(testMint)\W*
forge snapshot --asc --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --snap forge-snapshots/mint-1-Transfer.gas-snapshot --match-test \W*(TransferMintOne)\W*
forge snapshot --asc --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --snap forge-snapshots/mint-10-Transfer.gas-snapshot --match-test \W*(TransferMintTen)\W*
forge snapshot --asc --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --snap forge-snapshots/mint-100-Transfer.gas-snapshot --match-test \W*(TransferMintHundred)\W*
