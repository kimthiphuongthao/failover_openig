#!/bin/bash

# Exit on any error
set -e

# Cleanup function
cleanup() {
  echo "--- Cleaning up ---"
  docker-compose start openig-node1 > /dev/null 2>&1 || true
  docker-compose start openig-node2 > /dev/null 2>&1 || true
  echo "All nodes started."
}
trap cleanup EXIT

echo "--- Running Final Failover Test (JwtSession Success) ---"

# Ensure environment is up
docker-compose up -d --build

echo "Waiting for services to become healthy..."
MAX_RETRIES=15
RETRY_COUNT=0
until [[ $(docker ps --filter "name=openig-node" --filter "health=healthy" | wc -l) -ge 3 ]] || [ $RETRY_COUNT -eq $MAX_RETRIES ]; do
  echo "Waiting for nodes to be healthy (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)..."
  sleep 5
  RETRY_COUNT=$((RETRY_COUNT+1))
done

# Step 1: Initial request
echo "Step 1: Initial request to node..."
RESPONSE=$(curl -s -D - http://localhost:80/ -o /dev/null)

INITIAL_NODE=$(echo "$RESPONSE" | grep -i 'X-OpenIG-Node' | awk '{print $2}' | tr -d '\r')
SESSION_STATUS=$(echo "$RESPONSE" | grep -i 'X-Session-Status' | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//' | tr -d '\r')
COOKIE=$(echo "$RESPONSE" | grep -i 'Set-Cookie:' | grep 'JSESSIONID-JWT' | sed 's/Set-Cookie: //i' | cut -d';' -f1 | tr -d '\r')

echo "Initial node: $INITIAL_NODE"
echo "Session status: $SESSION_STATUS"

# Step 2: Stop the active node
echo "Step 2: Killing node (openig-$INITIAL_NODE)..."
docker-compose stop "openig-$INITIAL_NODE"
sleep 2

# Step 3: Failover request
echo "Step 3: Requesting failover node with the magic cookie..."
FAILOVER_RESPONSE=$(curl -s -D - -b "$COOKIE" http://localhost:80/ -o /dev/null)

FAILOVER_NODE=$(echo "$FAILOVER_RESPONSE" | grep -i 'X-OpenIG-Node' | awk '{print $2}' | tr -d '\r')
FAILOVER_STATUS=$(echo "$FAILOVER_RESPONSE" | grep -i 'X-Session-Status' | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//' | tr -d '\r')

echo "Failover node: $FAILOVER_NODE"
echo "Failover session status: $FAILOVER_STATUS"

if [[ "$FAILOVER_STATUS" == "RESUMED_FROM_initial-"* ]]; then
  echo ""
  echo "********************************************************"
  echo "S U C C E S S :  F A I L O V E R   C O N F I R M E D !"
  echo "********************************************************"
  echo "Session created on $INITIAL_NODE was successfully"
  echo "decrypted and resumed on $FAILOVER_NODE via JwtSession."
  echo "********************************************************"
else
  echo "ERROR: Session replication failed. Status: $FAILOVER_STATUS"
  exit 1
fi

exit 0
