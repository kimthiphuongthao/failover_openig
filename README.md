# OpenIG Failover and Load Balancing Test Environment

This project sets up a local environment using Docker to test the failover and load balancing capabilities of OpenIG with Apache Tomcat and `mod_jk`.

## Architecture

The environment consists of:
- **apache-lb**: An Apache HTTP Server acting as a load balancer using `mod_jk`. It listens on port 80.
- **openig-node1**: A Tomcat server running OpenIG on host port 8081.
- **openig-node2**: A Tomcat server running OpenIG on host port 8082.

Both Tomcat nodes are configured for session replication using Tomcat's built-in clustering feature.

## Prerequisites

1.  **Docker and Docker Compose**: Ensure you have them installed on your machine (macOS).
2.  **OpenIG.war**: Download the `OpenIG.war` file from the [OpenIG GitHub releases](https://github.com/OpenIdentityPlatform/OpenIG/releases).
3.  **mod_jk.so**: Download the `mod_jk.so` binary for Apache 2.4. You can find it on the [Tomcat Connectors download page](https://tomcat.apache.org/download-connectors.cgi).

## Setup Instructions

1.  **Place Required Files**:
    *   Place the downloaded `OpenIG.war` inside the `openig-base/` directory.
    *   Create a directory named `apache-lb` inside the project root.
    *   Place the downloaded `mod_jk.so` inside this new `apache-lb/` directory.

2.  **OpenIG Configuration**:
    *   Place your OpenIG configuration files (like `config.json`, `routes/`, etc.) inside the `configs/openig/` directory. This directory will be shared across both OpenIG nodes.

3.  **Build and Run the Environment**:
    ```bash
    docker-compose up --build
    ```

## How to Test

1.  **Access the application**: Open your browser and navigate to `http://localhost`. The load balancer will route your request to either `openig-node1` or `openig-node2`.
2.  **Verify Session Stickiness**: Open your browser's developer tools and check the `JSESSIONID` cookie. It should have a suffix like `.node1` or `.node2`. Refreshing the page should keep you on the same node.
3.  **Test Failover**:
    *   Perform an action that creates a session (e.g., log in through a protected route).
    *   Identify which node you are on (e.g., `.node1`).
    *   Stop that specific node using Docker:
        ```bash
        docker-compose stop openig-node1
        ```
    *   Refresh your browser. You should be seamlessly redirected to `openig-node2` without losing your session.
4.  **Check Load Balancer Status**:
    *   You can view the `mod_jk` status page by adding a port mapping for it if needed, but it's primarily for internal routing.

## Shutdown

To stop and remove all containers, run:
```bash
docker-compose down
```
