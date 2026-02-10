#!/bin/bash
set -e

echo "--- Running Route Debug Test ---"
docker-compose up -d --build > /dev/null 2>&1
echo "Waiting for services to start..."
sleep 15

echo "Making request to check for debug header..."
# Use -i to include headers in the output
RESPONSE=$(curl -s -i http://localhost)

echo "--- Response Headers ---"
echo "$RESPONSE" | grep -i "HTTP/"
echo "$RESPONSE" | grep -i "X-"
echo "------------------------"

if echo "$RESPONSE" | grep -q -i "X-Debug-Node"; then
  echo
  echo "--- SUCCESS: Debug test passed! The route is now loading correctly. ---"
  echo "The problem is confirmed to be related to session handling."
  exit 0
else
  echo
  echo "--- FAILURE: Debug test failed. X-Debug-Node header is still missing. ---"
  echo "The route is still not being loaded. Checking logs..."
  docker logs failover-test-environment-openig-node1-1
  exit 1
fi
