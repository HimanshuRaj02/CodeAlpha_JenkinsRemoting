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

## Validation and Limitations
- Three Jenkins agent containers were running: two Linux agents and one ARM64 agent.
- Jenkins remote execution succeeded on the Linux agents and ARM64 agent.
- The ARM64 job reported `aarch64` and Java 21.
- Build distribution was tested across the two Linux agents.
- Agents were attached to the dedicated Docker network `jenkins-remoting-net`.
- The ARM64 agent reached the controller on the Remoting port 50000. Its tested connection to the controller's default-bridge IP on port 8080 was blocked.
- Strict network isolation has not been fully proven.
- All agent containers run on the same host; execution across separate physical machines has not been tested.

## Evidence
Screenshots are available in the `evidence/` directory, including `security-connectivity-test.png` for Remoting and bridge connectivity tests. Verification scripts are available in `scripts/`.
