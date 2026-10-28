# Jenkins Remoting & Distributed Builds | CodeAlpha Task 2

A hands-on DevOps project demonstrating Jenkins Remoting, distributed build execution, Linux agents, ARM64 execution, and remote connectivity to an AWS EC2 Ubuntu virtual machine.

## 1. Project Objectives

- Configure Jenkins Remoting with multiple agents.
- Distribute builds across Linux agents.
- Execute a job on an ARM64 agent.
- Connect a remote AWS EC2 Ubuntu agent.
- Verify remote execution and network connectivity.
- Document security configuration, evidence, and limitations.

## 2. Architecture

![Jenkins Remoting Architecture](docs/architecture.png)

### Components

| Component | Role |
|---|---|
| Jenkins Controller | Runs in Docker on the local laptop using WSL |
| jenkins-agent-1 | Linux x86_64 agent, Java 21 |
| jenkins-agent-2 | Linux x86_64 agent, Java 21 |
| jenkins-arm64-agent | ARM64 agent, aarch64, Java 21 |
| aws-ubuntu-agent | Remote Jenkins agent on AWS EC2 Ubuntu |
| SSH reverse tunnel | Provides the EC2 agent a route to the local Jenkins controller |
| Evidence | Screenshots of builds, connectivity, packet capture, and security settings |

The local controller uses port 8080 for the Jenkins web interface. The SSH reverse tunnel exposes the controller to the EC2 agent through EC2 localhost port 18080. Jenkins agent communication uses the configured Remoting connection.

**Environment clarification:** AWS EC2 is a separate cloud virtual machine, not a second physical laptop. The local controller runs in Docker on the laptop; the AWS agent runs on an EC2 Ubuntu VM.

## 3. Technology Stack

- Jenkins
- Docker
- Linux / Ubuntu
- AWS EC2
- Java 21
- Jenkins Remoting
- SSH reverse tunneling
- TCP packet capture with tcpdump
- Git and GitHub

## 4. Verified Results

### Linux build distribution

The `CodeAlpha-Remoting-Test` job was executed on the configured Linux agents.

- Build #5 ran on `jenkins-agent-2`.
- Build #6 ran on `jenkins-agent-1`.

### ARM64 remote execution

The ARM64 build completed successfully and reported the `aarch64` architecture.

### AWS EC2 remote execution

A remote Jenkins agent named `aws-ubuntu-agent` was connected on an AWS EC2 Ubuntu VM.

- EC2 hostname observed: `ip-172-31-29-243`
- Java version: 21
- A remote test build completed successfully on the EC2 agent.

### Tunnel connectivity

The EC2 VM successfully accessed the Jenkins controller login endpoint through the reverse tunnel:

- EC2 request: `http://localhost:18080/login`
- Observed HTTP response: `200`
- Local controller endpoint on port 8080 also returned HTTP `200`.

### TCP packet capture

TCP traffic was captured on the EC2 VM using `tcpdump`. The captured output included traffic on the loopback interface for port 18080 and external TCP traffic on the EC2 network interface.

The observed external destination IP matched the public IP reported by the local machine at the time of testing. This supports correlation with the local network endpoint, but does not by itself prove that every captured packet was Jenkins application traffic.

## 5. Evidence

Screenshots are stored in the `evidence/` directory.

### AWS remote agent and build

- [AWS EC2 agent online](evidence/aws-ubuntu-agent-online.png)
- [AWS EC2 remote build success](evidence/aws-ubuntu-remote-build-success.png)
- [EC2 tunnel HTTP 200](evidence/ec2-tunnel-http-200.png)
- [Local controller HTTP 200](evidence/local-controller-http-200.png)
- [AWS packet capture](evidence/aws-ubuntu-packet-capture.png)

### Security configuration

- [Agent user and security check](evidence/agent-user-security.png)
- [Container security settings](evidence/container-security-settings.png)

Other existing build evidence includes the Linux agent builds, ARM64 build, Jenkins dashboard, and connectivity tests where those files are present in the repository.

## 6. Verification Scripts

The repository includes:

- [Environment verification](scripts/verify-environment.sh)
- [Agent verification](scripts/verify-agents.sh)

Review the scripts before running them. They require an environment with the relevant commands and Docker access.

## 7. Security Review and Limitations

### Container settings

The inspected controller and agent containers had `privileged=false`. The inspected agent containers did not have the Docker socket mounted.

However, `jenkins-agent-1` and `jenkins-agent-2` were observed running as root. This is a security-hardening opportunity; the agents should not be described as fully least-privilege until their runtime user and file permissions are reviewed and corrected safely.

### Network connectivity versus isolation

The tests verified selected connectivity paths, including the SSH reverse tunnel and the Jenkins controller endpoint. A test showing one port unreachable does not establish complete network isolation.

**Full node isolation has not been established by the evidence collected for this project.** The current results document tested endpoints and ports only. Do not interpret them as proof that all unapproved traffic is blocked.

### Scope

The project demonstrates local Docker-based distributed builds, ARM64 execution, and remote Jenkins execution on an AWS EC2 Ubuntu VM. It does not claim testing between two independently owned physical servers.

## 8. Project Status

The core Jenkins Remoting implementation and the documented Linux, ARM64, and AWS EC2 remote-build tests have been completed. Tunnel connectivity and TCP traffic were also captured as evidence.

Security findings and limitations are explicitly documented. Complete network isolation and least-privilege execution for the two Linux agents are not claimed as verified.

## 9. Repository Structure

```text
.
├── README.md
├── docs/
│   └── architecture.png
├── evidence/
└── scripts/
    ├── verify-environment.sh
    └── verify-agents.sh
```

## Author

**Himanshu Raj**  
**Program:** CodeAlpha DevOps Internship  
**Project:** Jenkins Remoting & Distributed Builds
