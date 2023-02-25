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



## Pricing Consideration for CDE

### Gitpod
- Up To 50 Hours of Usage/Month
- Standard: 4 Cores, 8GB Ram and 30GB Storage
- Avoid spinning multiple enviroment at the time as it consume your 50Hours free tier quicker.

To check the remain credit, click to your Icon > billing
 
 ### Github Codespaces
 2 flavours:
 - Up to 60 Hours of usage with 2 core 4GB RAM and 15GB of Storage
- Up to 30 Hours of usage with 4 core 8GB RAM and 15GB of Storage

### AWS Cloud9
- Covered under free tier if you use the T2.micro instance'
- Avoid using Cloud9 in case of free tier instance in use for other purpose.



## Docker

### Creating docker backend
To create the docker configuration for the backend-flask, create a file called **Dockerfile** and copy the following code

```
FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

from the project directory type the following code to build the image
```
docker build -t backend-flask ./backend-flask
```

typing this command to run the image of the container
```
docker run --rm -p 4567:4567 -it backend-flask
```


this code create the 2 var env and run the container

```
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
```

#### Creating docker frontend
move to the frontend folder and install npm
this command will be execute every time you launch the gitpod session
```
cd frontend-react-js
npm i
```

To create the docker configuration for the frontend-react-js, create a file called **Dockerfile** and copy the following code
```
FROM node:16.18

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```

### Create docker compose

Create the file called docker-compose.yml from the main root and copy the following code.
```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```


to run the docker compose, go to the docker compose and click ***docker up***

### Troubleshooting

This command check the images what image are on the local machine
```
docker images
```

this  command check the status of the container. good to see if it is running
```
docker ps
```


from docker extention, click the container image and go to  **attach shell** this open the shell on the contianer. use this tool for troubleshooting



I got problem commiting as I did some changes on github and the same time on gitpod. to solve 

```
git pull --rebase
git push
```

to enter to postgres on container type the following command
```
psql -Upostgres --host localhost
```