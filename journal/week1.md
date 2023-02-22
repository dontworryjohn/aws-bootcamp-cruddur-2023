# Week 1 — App Containerization

## **Security on Container**

This week the team will be talking about docker containers and the best practice.
I will write the 10 best practices that you need to know.


### **What is container Security?**
Container Security is the practice of protecting your application hosted on compute service like  containers.

### **Why container is popular?**
It is a angnostic way to run application.
Most people started developing apps on container due to the simplicity to pass the package without considering requirements.


**Managed Vs Unmanaged Container**

Managed Containers means that the Provider (AWS) managed the underlying service for the container (ECS or EKS). In this case Cloud provider will be managing the security prospective .

Unmanaged Containers means you are running your container on your servers and you have to manage all the system (for example you will be in charged to apply security patches).

(Please refer to the Share responsability diagram on the journal Week0.md).




### **Docker Components**
![Docker Component](https://docs.docker.com/engine/images/architecture.svg)

- Client is basically is installed your docker locally (build, pull, run features)
- Server is the location where is running the container

Registry is a location of the images available on internet (an exampple is docker hub). you could have a private registry inside of your organisation.

#### **Security Best Practice**
- Keep Host & Docker Updated to latest security patches.
- Docker Deamon & containers should run in non root user mode
- Image Vulnerability Scanning
- Trust a Private vs Public Image Registry
- No Sensitive Data in Docker Files or Images
- Use Secret Management Services to share secrets.
- Read only file system and volume for dockers
- Separate databases for long term storage
- Use DevSecOps pratices while building application security
- Ensure all code is tested for vulnerabilities before production use


#### **Docker Compose** 
It is a tool for defining and running multi container Docker Applications (It uses yml file).

### Tool to indefity vulnerability on your Docker Compose
Snyk OpenSource Security

### Tools to Store and Manage Secrets
- Aws Secret Manager
- Hashicorp Vault

### Tools to scan Image Vulnerability
- AWS Inspector
- Clair
- Snyk COntainer Security

### Running Containers in AWS
Problem with docker compose and Docker Containers: If you need to change, you need to stop the machine update the file and restart.

For the Managed Containers you can use the following AWS service
- AWS ECS
- AWS EKS
- AWS Fargate

Reason to run containers on the cloud
- Integration with AWS Services
- Using automation to provision containers at sale with speed and security

## Docker

'''
docker images
'''

from docker, click the container image and go to  **attach shell** this open the shell on the contianer


I got problem commiting as I did some changes on github and the same time on gitpod. to solve 
'''
git pull --rebase
git push
'''
