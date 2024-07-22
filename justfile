julia := "julia --project"

default:
    just --list

repl:
    {{julia}}

weave NOTEBOOK:
    {{julia}} scripts/weave.jl {{NOTEBOOK}}

test:
    {{julia}} test/runtests.jl

data:
    mkdir -p data
    curl -o data/eurusd.csv "https://query1.finance.yahoo.com/v7/finance/download/EURUSD%3DX?period1=1689408469&period2=1721030869&interval=1d&events=history&includeAdjustedClose=true"

clean:
    find notebooks/ -name "*.html" -type f -delete
