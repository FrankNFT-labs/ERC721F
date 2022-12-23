@echo off
cls
setlocal enabledelayedexpansion

set SNAPSHOT_FILES[0]=optimizer-disabled
set SNAPSHOT_FILES[1]=optimizer-200
set SNAPSHOT_FILES[2]=optimizer-1000

for /L %%j in (0,1,2) do (
    set SNAPSHOT_LOCATION_ASCENDED=forge-snapshots/BreakEven/!SNAPSHOT_FILES[%%j]!-ascended.gas.snapshot
    set SNAPSHOT_LOCATION_DESCENDED=forge-snapshots/BreakEven/!SNAPSHOT_FILES[%%j]!-descended.gas.snapshot

    if %%j == 0 (
        node .\scripts\js\update_foundry_optimizer.js false
        echo == Optimizer Disabled ==
    ) else (
        node .\scripts\js\update_foundry_optimizer.js true
        if %%j == 1 (
            node .\scripts\js\update_foundry_optimizer_runs.js 200
            echo == Optimizer - 200 runs ==
        ) else (
            node .\scripts\js\update_foundry_optimizer_runs.js 1000
            echo == Optimizer - 1000 runs ==
        )
    )

    for /L %%i in (0,10,100) do (
        if %%i == 0 (
            node .\scripts\js\update_env_breakeven_count.js 1
            echo ^> Began updating .env BREAK_EVEN_COUNT with value 1
        ) else (
            node .\scripts\js\update_env_breakeven_count.js %%i
            echo ^> Began updating .env BREAK_EVEN_COUNT with value %%i
        )
        echo Finished updating .env

        echo ^> Began executing BreakEven tests
        if not exist forge-snapshots mkdir forge-snapshots
        forge test --mc \bBreakEven\b --gas-report > forge-snapshots/temp.gas-snapshot
        echo Finished executing tests

        echo ^> Began writing results to respective files
        if not exist forge-snapshots\BreakEven mkdir forge-snapshots\BreakEven
        if %%i == 0 (
            for /f "delims=" %%i in ('findstr /C:"Function Name" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i > !SNAPSHOT_LOCATION_ASCENDED!)
            for /f "delims=" %%i in ('findstr /C:"Function Name" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i > !SNAPSHOT_LOCATION_DESCENDED!)
            for /f "delims=" %%i in ('findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> !SNAPSHOT_LOCATION_ASCENDED!)
            for /f "delims=" %%i in ('findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> !SNAPSHOT_LOCATION_DESCENDED!)

            echo. >> !SNAPSHOT_LOCATION_ASCENDED!
            echo. >> !SNAPSHOT_LOCATION_DESCENDED!
            echo Tokens transfered 1 >> !SNAPSHOT_LOCATION_ASCENDED!
            echo Tokens transfered 1 >> !SNAPSHOT_LOCATION_DESCENDED!
        ) else (
            echo. >> !SNAPSHOT_LOCATION_ASCENDED!
            echo. >> !SNAPSHOT_LOCATION_DESCENDED!
            echo Tokens transfered %%i >> !SNAPSHOT_LOCATION_ASCENDED!
            echo Tokens transfered %%i >> !SNAPSHOT_LOCATION_DESCENDED!
        )
        for /f "delims=" %%i in ('findstr /C:"transferAsc" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> !SNAPSHOT_LOCATION_ASCENDED!)
        for /f "delims=" %%i in ('findstr /C:"transferDesc" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> !SNAPSHOT_LOCATION_DESCENDED!)
        echo Finished writing results

        echo.
    )
)

del forge-snapshots\temp.gas-snapshot
