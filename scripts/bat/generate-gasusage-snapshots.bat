@echo off
cls

del forge-snapshots\ERC721FGasReporterMock.gas-snapshot

echo ^> Began testing of mint
forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(testMint)\W* --gas-report > forge-snapshots/temp.gas-snapshot
echo Finished mint tests
echo ^> Began writing results in respective file
node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
echo Finished writing results

echo.

echo ^> Began testing of transfers with 1 token minted
forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintOne)\W* --gas-report > forge-snapshots/temp.gas-snapshot
echo Fininshed transfer tests
echo ^> Began writing results in respective file
node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
echo Finished writing results

echo.

echo ^> Began testing of transfers with 10 tokens minted
forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintTen)\W* --gas-report > forge-snapshots/temp.gas-snapshot
echo Finished transfer tests
echo ^> Began writing results in respective files
node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
echo Finished writing results

echo.

echo ^> Began testing of transfers with 100 tokens minted
forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*(TransferMintHundred)\W* --gas-report > forge-snapshots/temp.gas-snapshot
echo Finished transfer tests
echo ^> Began writing results in respective files
node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot forge-snapshots/ERC721FGasReporterMock.gas-snapshot
echo Finished writing results

del forge-snapshots\temp.gas-snapshot
