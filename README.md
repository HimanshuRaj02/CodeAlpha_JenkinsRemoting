# Jenkins Remoting Project | CodeAlpha

A hands-on DevOps project demonstrating Jenkins Remoting, distributed builds, Linux agents, ARM64 remote execution, and network connectivity testing using Docker.

## Project Overview

The project uses a Jenkins Controller connected to multiple Jenkins agents. Jobs can run on different configured agents, and build execution can be verified through Jenkins console output.

## Objectives

- Configure Jenkins Remoting with remote agents.
- Distribute builds across Linux agents.
- Execute a job on an ARM64 agent.
- Test network connectivity between Jenkins components.
- Document verification results and security limitations.

## Architecture

The following diagram illustrates the project architecture and tested setup.

![Jenkins Remoting Architecture](docs/architecture.png)


**Environment note:** The controller and agents in this implementation run as Docker containers on the same physical host. A separate physical machine or cloud VM has not yet been verified.

## Environment

| Component | Configuration |
|---|---|
| Jenkins Controller | Docker container |
| Linux Agents | Two Linux agent containers |
| ARM64 Agent | ARM64 container using Java 21 |
| Networking | Dedicated Docker network |
| Build execution | Jenkins Remoting |
| Evidence | Screenshots and verification scripts |

## Verified Results

- Jenkins Controller and Linux agents configured.
- Remote execution test completed successfully.
- Load distribution verified: Build #5 ran on `jenkins-agent-2` and Build #6 ran on `jenkins-agent-1`.
- ARM64 job completed successfully and reported `aarch64`.
- Environment and agent verification scripts executed.
- Network connectivity tests performed and screenshots saved.

## Evidence

### Jenkins Dashboard — Successful Jobs and Agents

![Jenkins Dashboard Success](evidence/jenkins-dashboard-success.png)

### ARM64 Remote Build

![ARM64 Remote Build Success](evidence/arm64-remote-build-success.png)

## Verification Scripts

The repository includes scripts for checking the environment and Linux agents.

- [Verify Environment Script](scripts/verify-environment.sh)
- [Verify Agents Script](scripts/verify-agents.sh)

To inspect or run a script from the project directory:

```bash
cat scripts/verify-environment.sh
cat scripts/verify-agents.sh
```

Run the scripts in an environment where their required commands and Docker access are available.

## Repository Links

- [Architecture and Documentation — docs](docs/)
- [All Evidence Screenshots — evidence](evidence/)
- [Verification Scripts — scripts](scripts/)
- [Project Source and README](.)

## Security Testing and Limitations

Network connectivity tests were performed from the configured containers. The recorded test showed the Jenkins Remoting port `50000` was reachable, while the tested connection to the controller's other network address on port `8080` was blocked.

These results apply only to the tested source, destination, ports, and network configuration. They do not prove complete node isolation.

All controller and agent containers currently run on the same physical host. A separate physical machine or cloud VM has not been tested. Additional validation may be needed to fully demonstrate the requirement for build distribution across different machines.

## Project Status

The local Docker-based Jenkins Remoting setup, Linux load-distribution test, ARM64 build, and documented connectivity tests have been completed. Further remote-machine and security-isolation validation remains subject to review of the task requirements.

---

**Author:** Himanshu Raj  
**Program:** CodeAlpha DevOps Internship  
**Project:** Jenkins Remoting

---

**Author:** Himanshu Raj  
**Program:** CodeAlpha DevOps Internship  
**Project:** Jenkins Remoting
