# Whatap ECS Task and Sidecar Management

This program helps automate the creation and management of ECS tasks and services on AWS. It includes functionality to create necessary IAM roles, task definitions, and ECS services, and to add a Whatap sidecar container to existing task definitions.

## Purpose

The purpose of this program is to simplify the deployment and monitoring of ECS services using Whatap. It allows users to:

1. Create ECS task definitions and services.
2. Manage IAM roles required for ECS task execution and monitoring.
3. Add a Whatap sidecar container to existing ECS task definitions for enhanced monitoring.

## Requirements

- Go programming language installed.
- AWS CLI installed and configured with appropriate permissions.
- Whatap access key and host information.

## Usage

1. **Clone the repository**:
```bash
git clone https://github.com/yourusername/whatap-ecs-management.git
cd whatap-ecs-management
```
2. **Build the program**:
```bash
go build -o whatap_ecs ./whatap_ecs.go
```

3. **Run the program**:
```bash
./whatap_ecs
```
Follow the prompts to enter your Whatap access key, host, and other required information.

Run the generated scripts:

To create the task definition:
```bash
bash 01_whatap_single_task_definition.sh
```
To create the ECS service:
```bash
bash 02_whatap_single_service.sh
```
To update an existing task definition with the Whatap sidecar:
```bash
bash 03_user_task_definition_update.sh
```