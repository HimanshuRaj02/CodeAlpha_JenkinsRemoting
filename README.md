# CodeAlpha Jenkins Remoting

## Project Overview
This project demonstrates Jenkins Remoting using one Jenkins controller and two remote agent containers.

## Objectives
- Connect remote Jenkins agents to a controller.
- Execute jobs on remote agents.
- Test build distribution across multiple agents.
- Inspect Docker network configuration and connectivity.
- Verify ARM64 container emulation and Java 21 runtime.

## Environment
- Jenkins controller: `jenkins/jenkins:lts-jdk21`
- Agent runtime: `eclipse-temurin:21-jre`
- Container platform: Docker on Ubuntu/WSL
- Dedicated network: `jenkins-remoting-net`

## Architecture
The Jenkins controller and both agents run as Docker containers on the same host. Both agents are attached to `jenkins-remoting-net`. The controller is attached to that network and the default Docker bridge network.

## Verified Results
- Both Jenkins agents connected to the controller.
- Remote jobs executed successfully on both agents.
- Build-distribution tests ran on both agents.
- Both agents were confirmed on the dedicated Docker network.
- Both agents successfully reached the controller on port 50000.
- ARM64 container emulation returned `aarch64`.
- Java 21 ran successfully in an ARM64 container.

## Security Notes
The controller is connected to both `jenkins-remoting-net` and the default Docker bridge network. The controller's bridge IP was reachable from Agent 1. Dedicated network membership was verified, but strict network isolation has not been proven.

The ARM64 tests verified container emulation and Java runtime execution only. A Jenkins job executed successfully on the ARM64 agent, reporting aarch64 and Java 21.

## Evidence
Screenshots are stored in the `evidence/` directory.

## Project Status
This project is still in progress. Further tests, repeatable scripts, and final validation are pending.
