UNLOCK_ACCOUNTS=""
UNLOCK_ARGS=""
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

PUBLIC_IP_ARGS=""
if [[ -n "${NAT_PUBLIC_IP_AUTO}" ]]; then
  # Run for 60 seconds if fail
  WAIT=60
  SECONDS=0
  SLEEP=5
  while (( $SECONDS < $WAIT )); do
    PUBLIC_IP=$(curl -s -f -m 5 "${NAT_PUBLIC_IP_AUTO}")
    # Check if exit code is 0 and returned value is not empty
    if [[ $? -eq 0 && -n "${PUBLIC_IP}" ]]; then
      PUBLIC_IP_ARGS="--nat=extip:${PUBLIC_IP}"
      echo "Public: Set extip: ${PUBLIC_IP_ARGS}"
      break
    else
      echo "Can't get Public IP - Retry in $SLEEP seconds / $((WAIT - SECONDS))"
    fi
    # Sleep and check again
    sleep $SLEEP
  done
fi

if [ -n "$ENABLE_MINER" ]; then
    MINER_ARGS="--mine --miner.etherbase 0x10420A3dE36231E12eb601F45b4004311372dcEa"
else
    rm -Rf /root/.ethereum/geth
fi

echo "UNLOCK_ARGS: $UNLOCK_ARGS"
echo "MINER_ARGS: $MINER_ARGS"
echo "GETH_ARGS: $GETH_ARGS"
echo "PUBLIC_IP_ARGS: $PUBLIC_IP_ARGS"

geth init genesis.json
geth --networkid 789988 --http --http.addr 0.0.0.0 --allow-insecure-unlock --http.vhosts '*' $UNLOCK_ARGS $MINER_ARGS $PUBLIC_IP_ARGS $GETH_ARGS
exit 0
