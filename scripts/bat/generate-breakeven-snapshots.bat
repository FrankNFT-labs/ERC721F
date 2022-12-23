@echo off
cls

for /L %%i in (0,10,100) do (
    if %%i == 0 (
        node .\scripts\js\update_env_breakeven_count.js 1
        echo ^> Began updating .env with value 1
    ) else (
        node .\scripts\js\update_env_breakeven_count.js %%i
        echo ^> Began updating .env with value %%i
    )
    echo Finished updating .env

    echo ^> Began executing BreakEven tests
    forge test --mc \bBreakEven\b --gas-report > forge-snapshots/temp.gas-snapshot
    echo Finished executing tests

    echo ^> Began writing results to respective files
    if %%i == 0 (
        for /f "delims=" %%i in ('findstr /C:"Function Name" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i > forge-snapshots/BreakEven-ascended.gas.snapshot)
        for /f "delims=" %%i in ('findstr /C:"Function Name" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i > forge-snapshots/BreakEven-descended.gas.snapshot)
        for /f "delims=" %%i in ('findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> forge-snapshots/BreakEven-ascended.gas.snapshot)
        for /f "delims=" %%i in ('findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> forge-snapshots/BreakEven-descended.gas.snapshot)

        echo. >> forge-snapshots/BreakEven-ascended.gas.snapshot
        echo. >> forge-snapshots/BreakEven-descended.gas.snapshot
        echo Tokens transfered 1 >> forge-snapshots/BreakEven-ascended.gas.snapshot
        echo Tokens transfered 1 >> forge-snapshots/BreakEven-descended.gas.snapshot
    ) else (
        echo. >> forge-snapshots/BreakEven-ascended.gas.snapshot
        echo. >> forge-snapshots/BreakEven-descended.gas.snapshot
        echo Tokens transfered %%i >> forge-snapshots/BreakEven-ascended.gas.snapshot
        echo Tokens transfered %%i >> forge-snapshots/BreakEven-descended.gas.snapshot
    )
    for /f "delims=" %%i in ('findstr /C:"transferAsc" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> forge-snapshots/BreakEven-ascended.gas.snapshot)
    for /f "delims=" %%i in ('findstr /C:"transferDesc" .\forge-snapshots\temp.gas-snapshot') do (echo       %%i >> forge-snapshots/BreakEven-descended.gas.snapshot)
    echo Finished writing results

    echo.
)

del forge-snapshots\temp.gas-snapshot
