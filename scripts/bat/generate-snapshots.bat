cls
del forge-snapshots\ERC721FGasReporterMock.gas-snapshot

forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(testMint)\W* --gas-report > forge-snapshots/mint.gas-snapshot
node scripts/js/cleanup_snapshot.js forge-snapshots/mint.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
del forge-snapshots\mint.gas-snapshot

forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintOne)\W* --gas-report > forge-snapshots/mint-1-Transfer.gas-snapshot
node scripts/js/cleanup_snapshot.js forge-snapshots/mint-1-Transfer.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
del forge-snapshots\mint-1-Transfer.gas-snapshot

forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintTen)\W* --gas-report > forge-snapshots/mint-10-Transfer.gas-snapshot
node scripts/js/cleanup_snapshot.js forge-snapshots/mint-10-Transfer.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
del forge-snapshots\mint-10-Transfer.gas-snapshot

forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintHundred)\W* --gas-report > forge-snapshots/mint-100-Transfer.gas-snapshot
node scripts/js/cleanup_snapshot.js forge-snapshots/mint-100-Transfer.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
del forge-snapshots\mint-100-Transfer.gas-snapshot
