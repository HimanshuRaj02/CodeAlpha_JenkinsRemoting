#!/bin/bash
# Checks isolation for tested paths/ports and prints PASS/FAIL
AGENTS=(jenkins-agent-1 jenkins-agent-2 jenkins-arm64-agent)
CTRL=jenkins-controller
PORTS=(22 8080 50000)
pass=0; fail=0
ok(){ echo "  [PASS] $1"; pass=$((pass+1)); }
bad(){ echo "  [FAIL] $1"; fail=$((fail+1)); }
ip_of(){ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$1" | awk '{print $1}'; }

echo "1. Agent-to-agent traffic must be blocked (ports ${PORTS[*]})"
for src in "${AGENTS[@]}"; do
  for dst in "${AGENTS[@]}"; do
    [ "$src" = "$dst" ] && continue
    ip=$(ip_of "$dst"); allblocked=1
    for port in "${PORTS[@]}"; do
      out=$(docker exec "$src" bash -c "timeout 3 bash -c '</dev/tcp/$ip/$port'" 2>&1); rc=$?
      if [ $rc -eq 124 ] || echo "$out" | grep -qi "unreachable"; then :; else allblocked=0; fi
    done
    [ $allblocked -eq 1 ] && ok "$src -> $dst ($ip) blocked" || bad "$src -> $dst ($ip) REACHABLE"
  done
done

echo "2. Each agent must reach controller:50000 (Remoting)"
for a in "${AGENTS[@]}"; do
  docker exec "$a" bash -c "timeout 3 bash -c '</dev/tcp/$CTRL/50000'" >/dev/null 2>&1 \
    && ok "$a -> $CTRL:50000 open" || bad "$a -> $CTRL:50000 closed"
done

echo "3. Agent runtime: non-root, not privileged, no docker.sock"
for a in "${AGENTS[@]}"; do
  user=$(docker exec "$a" whoami)
  priv=$(docker inspect -f '{{.HostConfig.Privileged}}' "$a")
  sock=$(docker inspect -f '{{range .Mounts}}{{.Source}} {{end}}' "$a" | grep -c docker.sock)
  if [ "$user" != "root" ] && [ "$priv" = "false" ] && [ "$sock" = "0" ]; then
    ok "$a user=$user privileged=$priv docker.sock=no"
  else
    bad "$a user=$user privileged=$priv docker.sock_mounts=$sock"
  fi
done

echo "4. Nodes: EXCLUSIVE mode, label set, not offline"
for n in $(docker exec $CTRL ls /var/jenkins_home/nodes); do
  cfg=/var/jenkins_home/nodes/$n/config.xml
  mode=$(docker exec $CTRL sh -c "grep -oE '<mode>[A-Z]+' $cfg | sed 's/<mode>//'")
  label=$(docker exec $CTRL sh -c "grep -oE '<label>[^<]+' $cfg | sed 's/<label>//'")
  off=$(docker exec $CTRL sh -c "grep -c temporaryOfflineCause $cfg")
  if [ "$mode" = "EXCLUSIVE" ] && [ -n "$label" ] && [ "$off" = "0" ]; then
    ok "$n mode=$mode label=[$label]"
  else
    bad "$n mode=$mode label=[$label] offline_markers=$off"
  fi
done

echo
total=$((pass+fail))
echo "SUMMARY: $pass/$total checks passed"
if [ $fail -eq 0 ]; then
  echo "RESULT: PASS - isolation verified for tested paths and ports (scope: tested paths only)"
else
  echo "RESULT: FAIL - fix the [FAIL] lines above"
fi
