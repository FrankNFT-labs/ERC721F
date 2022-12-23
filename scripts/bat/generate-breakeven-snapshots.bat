@echo off

del forge-snapshots\BreakEven-ascended.gas.snapshot
del forge-snapshots\BreakEven-descended.gas.snapshot

for /L %%i in (0,10,100) do (
    if %%i == 0 (
        node .\scripts\js\update_env_breakeven_count.js 1
    ) else (
        node .\scripts\js\update_env_breakeven_count.js %%i
    )
    forge test --mc \bBreakEven\b --gas-report > forge-snapshots/temp.gas-snapshot

    if %%i == 0 (
        findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot | find /V "" >> forge-snapshots/BreakEven-ascended.gas.snapshot
        findstr /C:"mintHundred" .\forge-snapshots\temp.gas-snapshot | find /V "" >> forge-snapshots/BreakEven-descended.gas.snapshot
    )
    findstr /C:"transferAsc" .\forge-snapshots\temp.gas-snapshot | find /V "" >> forge-snapshots/BreakEven-ascended.gas.snapshot
    findstr /C:"transferDesc" .\forge-snapshots\temp.gas-snapshot | find /V "" >> forge-snapshots/BreakEven-descended.gas.snapshot
)
