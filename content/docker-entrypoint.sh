UNLOCK_ACCOUNTS=""
if [ -n "$UNLOCK_START_INDEX" ]; then
    INDEX=0
    END_INDEX=$(($UNLOCK_START_INDEX + $UNLOCK_NUMBER))
    while read p; do
        if [ "$INDEX" -ge "$UNLOCK_START_INDEX" ]; then
            if [ "$INDEX" -lt "$END_INDEX" ]; then
                cat passwordsource >> passwordfile
                UNLOCK_ACCOUNTS=$(echo $UNLOCK_ACCOUNTS$(echo $p | cut -d ',' -f 1), )
            fi
        fi
        INDEX=$(($INDEX + 1))
    done <accounts.csv

    UNLOCK_ARGS="--unlock "$UNLOCK_ACCOUNTS" --password passwordfile"
fi

echo "Starting geth..."

if [ -n "$ENABLE_MINER" ]; then
    MINER_ARGS="--mine --miner.etherbase 0x10420A3dE36231E12eb601F45b4004311372dcEa"
else
    rm -Rf /root/.ethereum/geth
fi

echo "UNLOCK_ARGS: $UNLOCK_ARGS"
echo "MINER_ARGS: $MINER_ARGS"
echo "GETH_ARGS: $GETH_ARGS"

geth init genesis.json
geth --networkid 789988 --http --http.addr 0.0.0.0 --allow-insecure-unlock --http.vhosts '*' $UNLOCK_ARGS $MINER_ARGS $GETH_ARGS
exit 0
