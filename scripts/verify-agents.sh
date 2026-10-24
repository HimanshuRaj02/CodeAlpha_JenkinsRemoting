#!/usr/bin/env bash
set -u

for agent in jenkins-agent-1 jenkins-agent-2; do
  echo
  echo "=== Checking $agent ==="

  if ! docker inspect -f '{{.State.Running}}' "$agent" | grep -qx true; then
    echo "FAIL: $agent is not running"
    exit 1
  fi

  echo "Container status: RUNNING"

  echo "Java version:"
  docker exec "$agent" java -version 2>&1 || exit 1

  echo "Architecture:"
  docker exec "$agent" uname -m || exit 1
done

echo
echo "Agent runtime checks completed successfully."
