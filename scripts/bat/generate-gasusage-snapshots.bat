@echo off
cls
setlocal enabledelayedexpansion

set SNAPSHOT_FILES[0]=optimizer-disabled.gas-snapshot
set SNAPSHOT_FILES[1]=optimizer-200.gas-snapshot
set SNAPSHOT_FILES[2]=optimizer-1000.gas-snapshot

if exist forge-snapshots\ERC721FGasReporterMock\optimizer-disabled.gas-snapshot del forge-snapshots\ERC721FGasReporterMock\optimizer-disabled.gas-snapshot
if exist forge-snapshots\ERC721FGasReporterMock\optimizer-200.gas-snapshot del forge-snapshots\ERC721FGasReporterMock\optimizer-200.gas-snapshot
if exist forge-snapshots\ERC721FGasReporterMock\optimizer-1000.gas-snapshot del forge-snapshots\ERC721FGasReporterMock\optimizer-1000.gas-snapshot

for /L %%i in (0,1,2) do (
    set SNAPSHOT_LOCATION=forge-snapshots/ERC721FGasReporterMock/!SNAPSHOT_FILES[%%i]!
    if %%i == 0 (
        node .\scripts\js\update_foundry_optimizer.js false 200
        echo == Optimizer Disabled ==
    ) else if %%i == 1 (
        node .\scripts\js\update_foundry_optimizer.js true 200
        echo == Optimizer - 200 runs ==
    ) else (
        node .\scripts\js\update_foundry_optimizer.js true 1000
        echo == Optimizer - 1000 runs ==
    )

    echo ^> Began testing of mint
    if not exist forge-snapshots mkdir forge-snapshots
    forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*^(testMint^)\W* --gas-report > forge-snapshots/temp.gas-snapshot
    echo Finished mint tests
    echo ^> Began writing results in respective file
    node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot !SNAPSHOT_LOCATION!
    echo Finished writing results

    echo.

    echo ^> Began testing of transfers with 1 token minted
    forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*^(TransferMintOne^)\W* --gas-report > forge-snapshots/temp.gas-snapshot
    echo Fininshed transfer tests
    echo ^> Began writing results in respective file
    node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot !SNAPSHOT_LOCATION!
    echo Finished writing results

    echo.

    echo ^> Began testing of transfers with 10 tokens minted
    forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*^(TransferMintTen^)\W* --gas-report > forge-snapshots/temp.gas-snapshot
    echo Finished transfer tests
    echo ^> Began writing results in respective files
    node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot !SNAPSHOT_LOCATION!
    echo Finished writing results

    echo.

    echo ^> Began testing of transfers with 100 tokens minted
    forge test --mc \bERC721FGasReporterMockTest\b --match-test \W*^(TransferMintHundred^)\W* --gas-report > forge-snapshots/temp.gas-snapshot
    echo Finished transfer tests
    echo ^> Began writing results in respective files
    node scripts/js/cleanup_snapshot.js forge-snapshots/temp.gas-snapshot !SNAPSHOT_LOCATION!
    echo Finished writing results
    
    echo.
)

del forge-snapshots\temp.gas-snapshot