@echo off

for /L %%i in (0,10,100) do (
    if %%i == 0 (
        node .\scripts\js\update_env_breakeven_count.js 1
    ) else (
        node .\scripts\js\update_env_breakeven_count.js %%i
    )
    forge test --mc \bBreakEven\b --gas-report -vvv
)
