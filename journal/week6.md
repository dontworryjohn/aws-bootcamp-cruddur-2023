# Week 6 — Deploying Containers
This week the team will be talking about ECS.

# Security in ECS/EKS/FARGATE

Before speaking of security, let's dive a little bit into the type of Container Services in AWS.

- Deploying the container inside the EC2 (Virtual Machine)
- Deploying using AWS services such as ECS, Fargate or EKS

Below you find the Share Responsibility depending of the service used

![Share reposonsabilities difference](https://d2908q01vomqb2.cloudfront.net/c5b76da3e608d34edb07244cd9b875ee86906328/2021/08/30/figure-1-ecs.jpg)

Security Challenges with Fargate:
- No visibility of infrastructure as this is managed by the cloud providerEphemeral Resources make it hard to triage or Forensics for detected threats
- No file/network monitoring
- Cannot run traditional security agents in fargate
- Users can run the unverified container image
- The container can run as root and even with elevated privileges.


Amazon ECS Side- Security Best Practice
- Cloud Control Plane Configuration (who has access, who can create images, who can create containers, what is the lifecycle of the images)
-  Choosing between public or private images repositories (ECR).
- Amazon ECR scan Images to "Scan on push" using Basic or Enhanced (Inspector + Snyk)
- Use VPC Endpoint or Security Group with known source only
- Compliance standard is what your business requires
- Amazon Organization CSP (Manage ECS Task Deletion, ECS Creation, Region Lock, etc) [Ashish Policies template](https://github.com/hashishrajan/aws-scp-best-practice-policies)
- AWS Cloudtrail to audit activities and discover malicious ECS behaviour by an identity in AWS.
- AWS Config Rule is enabled in the account and region of ECS.

Application Side- Security Best Practice
- Access Control - Role or IAM users for ECS Clusters/Services/Task
- Most Recent Version of ECS agent Daemon on EC2.
- Container Control Plane Configuration - Root Privileges, resource limitations etc.
- No secret/ Passwords in ECS task definition (For security purposes user/password to access DB must be done using the secret manager)
- Only use trusted containers from ecr with no high/critical vulnerabilities
- Limit ability to SSH into EC2 container to read only file system - use API or GitOps to put information for troubleshooting.
- Amazon Cloudwatc to monitor Malicious ECS Configuration Changes.
- Only using Authorized Container Images 

# Cost

Fargate

# Implementation

Reference
![Ashish Video Cloud Security Podcast](https://www.youtube.com/watch?v=zz2FQAk1I28&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=58)