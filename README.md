# Jenkins Remoting & Distributed Builds | CodeAlpha Task 2

A hands-on DevOps project demonstrating Jenkins Remoting, distributed build execution across Linux agents, ARM64 execution, and remote build execution on an AWS EC2 Ubuntu instance.

## 1. Project Objectives

- Configure a Jenkins controller with multiple build agents.
- Execute builds remotely on Linux x86_64 agents.
- Validate ARM64 build execution using the `aarch64` architecture.
- Connect a remote AWS EC2 Ubuntu agent through an SSH reverse tunnel.
- Verify Jenkins connectivity and distributed build execution.
- Apply Docker container security controls and network segmentation.
- Document implementation, validation results, and supporting evidence.

## 2. Architecture

![Jenkins Remoting Architecture](docs/architecture.png)

### Components

| Component | Role |
|---|---|
| Jenkins Controller | Runs in Docker on the local laptop using WSL |
| `jenkins-agent-1` | Linux x86_64 agent running Java 21 |
| `jenkins-agent-2` | Linux x86_64 agent running Java 21 |
| `jenkins-arm64-agent` | ARM64 agent running Java 21 |
| `aws-ubuntu-agent` | Remote Jenkins agent on an AWS EC2 Ubuntu VM |
| SSH reverse tunnel | Provides the EC2 agent with a route to the local Jenkins controller |
| Docker networks | Provide network segmentation for the local Linux agents |
| Evidence directory | Contains screenshots of builds, connectivity, network validation, and security settings |

The Jenkins web interface is available on port `8080` on the local environment. The SSH reverse tunnel exposes the controller endpoint to the EC2 agent through EC2 localhost port `18080`.

The local Linux agents use separate internal Docker networks, with the Jenkins controller connected to each network. The ARM64 agent uses `jenkins-remoting-net`, which also connects the controller. The AWS agent runs on a separate EC2 Ubuntu virtual machine.

**Environment clarification:** The AWS EC2 instance is a cloud virtual machine, not a second physical laptop.

## 3. Technology Stack

- Jenkins and Jenkins Remoting
- Docker and Docker networking
- Linux and Ubuntu
- Java 21
- AWS EC2
- SSH reverse tunneling
- TCP packet capture using `tcpdump`
- Git and GitHub
- Shell scripting

## 4. Implementation and Verified Results

### 4.1 Linux Distributed Builds

The `CodeAlpha-Remoting-Test` Jenkins job was used to verify remote execution on the Linux agents.

The test commands included:

```bash
echo "Node: $NODE_NAME"
hostname
uname -m
whoami
```

The results confirmed remote execution on both Linux agents.

- Build #5 executed on `jenkins-agent-2`.
- Build #6 executed on `jenkins-agent-1`.
- Both agents reported the `x86_64` architecture.
- The agents ran under the `jenkins-agent` user.

### 4.2 ARM64 Remote Execution

The ARM64 agent successfully executed a Jenkins build.

The build output confirmed:

- Agent: `arm64-agent`
- Architecture: `aarch64`
- Runtime user: `jenkins`
- Build result: `SUCCESS`

ARM64 execution was validated using an ARM64-compatible Java 21 agent image and QEMU-based architecture emulation on the local x86_64 Docker environment.

### 4.3 AWS EC2 Remote Execution

A remote Jenkins agent named `aws-ubuntu-agent` was connected to the controller from an AWS EC2 Ubuntu virtual machine.

Validation included:

- Agent connectivity in Jenkins.
- Java 21 availability.
- Successful remote build execution.
- Controller endpoint connectivity through the SSH reverse tunnel.

### 4.4 SSH Reverse Tunnel Validation

The Jenkins controller endpoint was tested through the reverse tunnel from the EC2 instance.

| Test | Result |
|---|---|
| EC2 request to `http://localhost:18080/login` | HTTP 200 |
| Local controller endpoint on port 8080 | HTTP 200 |

These results confirm that the tested HTTP endpoints were reachable during validation.

### 4.5 TCP Packet Capture

TCP traffic was captured on the EC2 instance using `tcpdump`.

The captured output included loopback traffic involving port `18080` and TCP traffic on the EC2 network interface. The observations were used to examine network communication during the remote-agent setup.

## 5. Network Segmentation and Connectivity Validation

### 5.1 Linux Agent Networks

The two Linux agents are connected to separate Docker bridge networks configured with internal networking.

| Docker network | Configuration | Connected containers |
|---|---|---|
| `jenkins-agent-1-net` | Internal | `jenkins-agent-1`, `jenkins-controller` |
| `jenkins-agent-2-net` | Internal | `jenkins-agent-2`, `jenkins-controller` |
| `jenkins-remoting-net` | Non-internal | `jenkins-arm64-agent`, `jenkins-controller` |

This configuration separates the two Linux agents at the Docker network level while preserving their connections to the Jenkins controller.

### 5.2 Connectivity Tests

Connectivity tests were performed between the Linux agents using their container IP addresses. The tested connection attempts failed, and the routing test returned `Network is unreachable` for the tested destinations.

The isolation validation screenshot records the checks performed during testing.

These results demonstrate the behavior observed for the tested network paths and ports.

### 5.3 Jenkins Node Usage

Jenkins node usage was configured to restrict jobs to nodes matching their assigned labels.

| Node | Labels |
|---|---|
| Linux Agent 1 | `linux-amd64`, `linux-agent-1` |
| Linux Agent 2 | `linux-amd64`, `linux-agent-2` |
| ARM64 Agent | `arm64` |
| AWS Ubuntu Agent | `aws-ubuntu` |

The Linux agents and ARM64 agent were validated with label-specific builds. The AWS agent was validated through remote build execution.

## 6. Container Security

The inspected agent containers were configured with security controls appropriate to their runtime setup.

### Linux Agent Hardening

- Dedicated non-root runtime user: `jenkins-agent` (`10001:10001`).
- Read-only container root filesystem.
- Linux capabilities dropped using `--cap-drop ALL`.
- `no-new-privileges` enabled.
- Size-limited temporary filesystems for `/tmp` and `/home/jenkins/agent`.
- No Docker socket mount in the inspected agent containers.
- Non-privileged container configuration.

### ARM64 Agent

The ARM64 agent successfully executed a build under the `jenkins` user. Its runtime configuration and successful build are documented in the project evidence.

### Jenkins Node Restrictions

The Jenkins nodes use label-based job restrictions with the usage mode **Only build jobs with label expressions matching this node**. This helps prevent jobs without matching label expressions from being scheduled on those nodes.

## 7. Evidence

All project screenshots are stored in the `evidence/` directory.

### Jenkins and Linux Builds

- [Jenkins nodes online](evidence/jenkins-nodes-online.png)
- [Jenkins dashboard](evidence/jenkins-dashboard-success.png)
- [Remote execution success](evidence/remote-execution-success.png)
- [Linux Agent 1 build](evidence/build-6-linux-agent-1.jpg)
- [Linux Agent 2 build](evidence/build-5-linux-agent-2.jpg)

### ARM64 Execution

- [ARM64 remote build success](evidence/arm64-remote-build-success.png)

### AWS EC2 Remote Execution

- [AWS Ubuntu agent online](evidence/aws-ubuntu-agent-online.png)
- [AWS Ubuntu remote build success](evidence/aws-ubuntu-remote-build-success.png)
- [EC2 tunnel HTTP 200](evidence/ec2-tunnel-http-200.png)
- [Local controller HTTP 200](evidence/local-controller-http-200.png)
- [AWS Ubuntu packet capture](evidence/aws-ubuntu-packet-capture.png)

### Network and Security Validation

- [Agent isolation validation](evidence/agent-isolation-validation.png)
- [Jenkins Remoting network](evidence/jenkins-remoting-network.png)
- [Security connectivity test](evidence/security-connectivity-test.png)
- [Agent user security](evidence/agent-user-security.png)
- [Container security settings](evidence/container-security-settings.png)

## 8. Verification Scripts

The repository includes scripts for environment and agent verification:

- [Environment verification script](scripts/verify-environment.sh)
- [Agent verification script](scripts/verify-agents.sh)

Review the scripts before execution. They require the relevant commands, Docker access, and a compatible environment.

## 9. Repository Structure

```text
.
├── README.md
├── Dockerfile.agent
├── docs/
│   └── architecture.png
├── evidence/
│   ├── agent-isolation-validation.png
│   ├── agent-user-security.png
│   ├── arm64-remote-build-success.png
│   ├── aws-ubuntu-agent-online.png
│   ├── aws-ubuntu-packet-capture.png
│   ├── aws-ubuntu-remote-build-success.png
│   ├── container-security-settings.png
│   ├── jenkins-dashboard-success.png
│   ├── jenkins-nodes-online.png
│   └── ...
└── scripts/
    ├── verify-environment.sh
    └── verify-agents.sh
```

## 10. Project Status

The project demonstrates distributed Jenkins builds across Linux agents, successful ARM64 execution, and remote execution on AWS EC2 Ubuntu.

The controller and agents were validated through Jenkins builds, connectivity checks, Docker network inspection, and security configuration checks. Supporting screenshots are included in the repository for review.

## Author

**Himanshu Raj**  
**Program:** CodeAlpha DevOps Internship  
**Project:** Jenkins Remoting & Distributed Builds
