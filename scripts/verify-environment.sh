#!/usr/bin/env bash
set -u

echo "=== Jenkins Remoting Environment Verification ==="

echo
echo "[1] Docker version"
docker --version || exit 1

echo
echo "[2] Jenkins containers"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'

echo
echo "[3] Dedicated network membership"
docker network inspect jenkins-remoting-net \
  --format '{{range .Containers}}{{.Name}} | {{.IPv4Address}}{{println}}{{end}}' || exit 1

echo
echo "[4] ARM64 architecture emulation"
docker run --rm --platform linux/arm64 eclipse-temurin:21-jre uname -m || exit 1

echo
echo "Environment verification finished."
