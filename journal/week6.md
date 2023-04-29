# Week 6 — Deploying Containers and DNS
This week the team will be talking about ECS, DNS

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

# Security of website using route 53

Let's understand what is the website: it is an application exposed using a custom domain. (An example is www.facebook.com) 

AWS Security Best Practice (Route 53)
- Integration With Amazon Certificate Manager for TLS
- Compliance Standard is what your business requires for a DNS provider
- Amazon Organization SCP - To manage route 53 actions like creation, deletion, modification of production URIs etc.
- AWS CloudTrail is enabled & monitored to trigger alerts for malicious activities e.g Associate VPC with hosted zone, change resource record set, register domain etc.
- Guardduty is enabled for monitoring suspicious DNS comms (e.g Crypto-mining etc) and automated for auto-remediation.
- AWS Config Rules is enabled in the account and region of ECS

Security Best Practice - Application (Route53)
- Access Control - Role or IAM users for making DNS changes in Amazon Route53
- Public vs Private Hosted Zone
- All route 53 records should point to an existing DNS, ELB, ALB or AWS S3
- Hosted Zone Configuration Changes Limited to a small set of people.
- Enable Encryption in Transit using TLS/SSL certification
- Only use trusted domain providers for requesting new DNSs
- Set TTL appropriately to afford to wait for a change to take effect
- Ensure Root Domain Alias Record point to ELB
-Develop process for continuously verifying  if DNS (& Hosted Zone) are al current and valid


# Cost

This Week Cirag did not post any video about cost so I did some research.

Fargate: There is no free tier for this service. The cost is payg and no upfront cost. Please refer the aws calculator for [fargate](https://calculator.aws/#/addService/Fargate)

ELB: If it is your new account, AWS offers a free tier for 12 months for this service. you receive a 750 hours per month shared between classic load balancer and application load balancer. 15 Gb of data processing for classic load balancer and 15 LCU for application Load balancer

AWS Certificate Manager: Public SSL/TLS certificates provisioned through AWS Certificate Manager are free.



# Implementation

this is week we start to implementation on AWS ecs with fargate


First we need to create a script to check if we can estabilish a connection with the RDS

this is the script
backend-flask/bin/db/test

```
#!/usr/bin/env python3

import psycopg
import os
import sys

connection_url = os.getenv("PROD_CONNECTION_URL")

conn = None
try:
  print('attempting connection')
  conn = psycopg.connect(connection_url)
  print("Connection successful!")
except psycopg.Error as e:
  print("Unable to connect to the database:", e)
finally:
  conn.close()

```
change the chmod u+x

The next steps is to create a health check of our backend-flask container
add the following code inside the app.py and remove the rollbar test

```
@app.route('/api/health-check')
def health_check():
  return {'success': True}, 200
```



We'll create a new bin script on bin/flask/health-check

```
#!/usr/bin/env python3

import urllib.request

try:
  response = urllib.request.urlopen('http://localhost:4567/api/health-check')
  if response.getcode() == 200:
    print("[OK] Flask server is running")
    exit(0) # success
  else:
    print("[BAD] Flask server is not running")
    exit(1) # false
# This for some reason is not capturing the error....
#except ConnectionRefusedError as e:
# so we'll just catch on all even though this is a bad practice
except Exception as e:
  print(e)
  exit(1) # false
```
change the chmod u+x

The next step is to create the cloudwatch log group. use the following command using the terminal
```
aws logs create-log-group --log-group-name "/cruddur/fargate-cluster"
aws logs put-retention-policy --log-group-name "/cruddur/fargate-cluster" --retention-in-days 1
```


The next step is to create the container registry the images

in this steps we will create the cluster in cli

```
aws ecs create-cluster \
--cluster-name cruddur \
--service-connect-defaults namespace=cruddur
```

the next steps is to prepare our docker.
first we need to create 3 repo in ERC. 1st for Python, 2nd for backend-flask and 3rd for frontend-react-js

First we need to login to ECR using the following command (Note this has to be done everytime you need to connect to ECR)
```
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"

```


using the cli we will create the python repo
```
aws ecr create-repository \
  --repository-name cruddur-python \
  --image-tag-mutability MUTABLE
```

and use the following command using the cli to set the url of the repo created before
```
export ECR_PYTHON_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cruddur-python"
echo $ECR_PYTHON_URL
```

the following command will pull the python:3.10-slim-buster, tag the image and push to the repo in ECR
```
docker pull python:3.10-slim-buster
docker tag python:3.10-slim-buster $ECR_PYTHON_URL:3.10-slim-buster
docker push $ECR_PYTHON_URL:3.10-slim-buster
```

from the dockerfile of backend-fask change the following line
```
FROM python:3.10-slim-buster

ENV FLASK_ENV=development
````
with
```
FROM 238967891447.dkr.ecr.eu-west-2.amazonaws.com/cruddur-python

ENV FLASK_DEBUG=1
```
Note:
- to make sure if it works, try to do Compose Up 
- to remove an image use the following code docker image rm nameoffile:tag
- to check the images of docker use docker images

the command to compose using the cli is the following
```
docker compose up backend-flask db
```

next is to create the repo for the backend flask
using the cli, launch this code
```
aws ecr create-repository \
  --repository-name backend-flask \
  --image-tag-mutability MUTABLE
```

and use the following command using the cli to set the url of the repo created before
```
export ECR_BACKEND_FLASK_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend-flask"
echo $ECR_BACKEND_FLASK_URL
```

now it is time to build the backend-flask image(make sure you are inside the directory)
```
docker build -t backend-flask .
```

and then tag it
```
docker tag backend-flask:latest $ECR_BACKEND_FLASK_URL:latest
```

and finally push to our repo

```
docker push $ECR_BACKEND_FLASK_URL:latest
```

IN THIS STEPS WE START TO CREATE THE CONTAINER

create the policies for the container

First we need to pass the parameters to the ssm 
```
export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=$HONEYCOMB_API_KEY"
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/AWS_ACCESS_KEY_ID" --value $AWS_ACCESS_KEY_ID
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/AWS_SECRET_ACCESS_KEY" --value $AWS_SECRET_ACCESS_KEY
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/CONNECTION_URL" --value $PROD_CONNECTION_URL
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/ROLLBAR_ACCESS_TOKEN" --value $ROLLBAR_ACCESS_TOKEN
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/OTEL_EXPORTER_OTLP_HEADERS" --value "x-honeycomb-team=$HONEYCOMB_API_KEY"
```

create the new trust entities json file under this path aws/policies/service-assume-role-execution-policy.json

```
{
  "Version":"2012-10-17",
  "Statement":[{
      "Action":["sts:AssumeRole"],
      "Effect":"Allow",
      "Principal":{
        "Service":["ecs-tasks.amazonaws.com"]
    }}]
}

```

Create another json file under this path aws/policies/service-execution-policy.json
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/*"
        }
    ]
}
```



and run using the following commands on CLI
```
aws iam create-role \
    --role-name CruddurServiceExecutionRole \
    --assume-role-policy-document file://aws/policies/service-assume-role-execution-policy.json
```


```
aws iam put-role-policy \
    --policy-name CruddurServiceExecutionPolicy \
    --role-name CruddurServiceExecutionRole  \
    --policy-document file://aws/policies/service-execution-policy.json
```

via console attach the following policy:
make sure to attach to the CruddurServiceExecutionRole the CloudWatchFullAccess


now we create the taskrole

```
aws iam create-role \
    --role-name CruddurTaskRole \
    --assume-role-policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[\"sts:AssumeRole\"],
    \"Effect\":\"Allow\",
    \"Principal\":{
      \"Service\":[\"ecs-tasks.amazonaws.com\"]
    }
  }]
}"
```

this attach the policy for SSM
```
aws iam put-role-policy \
  --policy-name SSMAccessPolicy \
  --role-name CruddurTaskRole \
  --policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[
      \"ssmmessages:CreateControlChannel\",
      \"ssmmessages:CreateDataChannel\",
      \"ssmmessages:OpenControlChannel\",
      \"ssmmessages:OpenDataChannel\"
    ],
    \"Effect\":\"Allow\",
    \"Resource\":\"*\"
  }]
}
```

pass this code to give access to cloudwatch to the cruddurtaskrole
```
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess --role-name CruddurTaskRole
```
this command attach a policy to write to the xraydaemon
```
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess --role-name CruddurTaskRole
```

now we create the task definition via cli

create a new file /aws/task-definitions/backend-flask.json

```
{
  "family": "backend-flask",
  "executionRoleArn": "arn:aws:iam::238967891447:role/CruddurServiceExecutionRole",
  "taskRoleArn": "",
  "networkMode": "awsvpc",
  "cpu": "256",
  "memory": "512",
  "requiresCompatibilities": [ 
    "FARGATE" 
  ],
  "containerDefinitions": [
    {
      "name": "backend-flask",
      "image": "238967891447.dkr.ecr.eu-west-2.amazonaws.com/backend-flask",
      "essential": true,
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "python /backend-flask/bin/flask/health-check"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "portMappings": [
        {
          "name": "backend-flask",
          "containerPort": 4567,
          "protocol": "tcp", 
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "cruddur",
            "awslogs-region": "eu-west-2",
            "awslogs-stream-prefix": "backend-flask"
        }
      },
      "environment": [
        {"name": "OTEL_SERVICE_NAME", "value": "backend-flask"},
        {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "https://api.honeycomb.io"},
        {"name": "AWS_COGNITO_USER_POOL_ID", "value": "eu-west-2_rNUe2sEXo"},
        {"name": "AWS_COGNITO_USER_POOL_CLIENT_ID", "value": "3870k3kbsr6tbkj6bltab924bp"},
        {"name": "FRONTEND_URL", "value": "*"},
        {"name": "BACKEND_URL", "value": "*"},
        {"name": "AWS_DEFAULT_REGION", "value": "eu-west-2"}
      ],
      "secrets": [
        {"name": "AWS_ACCESS_KEY_ID"    , "valueFrom": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/AWS_ACCESS_KEY_ID"},
        {"name": "AWS_SECRET_ACCESS_KEY", "valueFrom": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/AWS_SECRET_ACCESS_KEY"},
        {"name": "CONNECTION_URL"       , "valueFrom": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/CONNECTION_URL" },
        {"name": "ROLLBAR_ACCESS_TOKEN" , "valueFrom": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/ROLLBAR_ACCESS_TOKEN" },
        {"name": "OTEL_EXPORTER_OTLP_HEADERS" , "valueFrom": "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/OTEL_EXPORTER_OTLP_HEADERS" }
      ]
    }
  ]
}
```

and launch using the following command

```
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/backend-flask.json
```

next we need to find the default vpc
```
export DEFAULT_VPC_ID=$(aws ec2 describe-vpcs \
--filters "Name=isDefault, Values=true" \
--query "Vpcs[0].VpcId" \
--output text)
echo $DEFAULT_VPC_ID
```

and the security group
```
export CRUD_SERVICE_SG=$(aws ec2 create-security-group \
  --group-name "crud-srv-sg" \
  --description "Security group for Cruddur services on ECS" \
  --vpc-id $DEFAULT_VPC_ID \
  --query "GroupId" --output text)
echo $CRUD_SERVICE_SG
```

```
aws ec2 authorize-security-group-ingress \
  --group-id $CRUD_SERVICE_SG \
  --protocol tcp \
  --port 4567 \
  --cidr 0.0.0.0/0
  ```

  Create a file called service-backend-flask.json under the path /aws/json/
  replace the value of security group and subnetmask
```
{
  "cluster": "cruddur",
  "launchType": "FARGATE",
  "desiredCount": 1,
  "enableECSManagedTags": true,
  "enableExecuteCommand": true,
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "assignPublicIp": "ENABLED",
      "securityGroups": [
        "TO CHANGE"
      ],
      "subnets": [
        "TO CHANGE",
        "TO CHANGE",
        "TO CHANGE"
      ]
    }
  },
  "propagateTags": "SERVICE",
  "serviceName": "backend-flask",
  "taskDefinition": "backend-flask",
  "serviceConnectConfiguration": {
    "enabled": true,
    "namespace": "cruddur",
    "services": [
      {
        "portName": "backend-flask",
        "discoveryName": "backend-flask",
        "clientAliases": [{"port": 4567}]
      }
    ]
  }
}
```

if you need the to get the default subnet mask follow the following code (relaunch the on the line 414 if needed)

```
export DEFAULT_SUBNET_IDS=$(aws ec2 describe-subnets  \
 --filters Name=vpc-id,Values=$DEFAULT_VPC_ID \
 --query 'Subnets[*].SubnetId' \
 --output json | jq -r 'join(",")')
echo $DEFAULT_SUBNET_IDS
```

launch the following command to create the new for the backend flask so that the enable executecommand is active (Note that this function can active only using the CLI)

```
aws ecs create-service --cli-input-json file://aws/json/service-backend-flask.json

```


how to connect to the containers using the session manager tool for ubuntu

install the session manager. here is the [reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux)

```
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"


sudo dpkg -i session-manager-plugin.deb

session-manager-plugin

```

connect to the command
```
aws ecs execute-command  \
    --region $AWS_DEFAULT_REGION \
    --cluster cruddur \
    --task TOCHANGED \
    --container backend-flask \
    --command "/bin/bash" \
    --interactive
  ```

Note: the execute command is possible to active via console. therefore need to be recreate the task/service via cli

add the following code inside the gitpod.yml

```
name: fargate
    before: |
      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
      sudo dpkg -i session-manager-plugin.deb
      cd backend-flask

```

create the new folder called ssm inside the following path
/backend-flask/bin/
and create the new file connect-to-service and apply the chmod u+x

```
#! /usr/bin/bash

if [ -z "$1" ]; then
    echo "No TASK_ID argument supplied eg ./bin/ecs/connect-to service 291661114f174777aeeaff30522b972d backend-flask"
    exit 1
fi
TASK_ID=$1

if [ -z "$2" ]; then
    echo "No CONTAINER_NAME argument supplied eg ./bin/ecs/connect-to service 291661114f174777aeeaff30522b972d backend-flask"
    exit 2
fi
CONTAINER_NAME=$2


aws ecs execute-command  \
    --region $AWS_DEFAULT_REGION \
    --cluster cruddur \
    --task $TASK_ID \
    --container $CONTAINER_NAME \
    --command "/bin/bash" \
    --interactive
```


create load balancer to set in front of the backend container

add the following code on your service-backend-flask.json

```
"loadBalancers": [
      {
          "targetGroupArn": "",
          "containerName": "",
          "containerPort": 0
      }
    ],
```
on the targetGroupArn insert the arn ot the target group in this case the targetgroup for the backend-flask
on containername backend-flask
on containport 4567

We create the task for the frontend-react-js.

first crete the task definitiion called frontend-react-js.json under /aws/task-definition
```sh
"family": "frontend-react-js",
    "executionRoleArn": "arn:aws:iam::238967891447:role/CruddurServiceExecutionRole",
    "taskRoleArn": "arn:aws:iam::238967891447:role/CruddurTaskRole",
    "networkMode": "awsvpc",
    "cpu": "256",
    "memory": "512",
    "requiresCompatibilities": [ 
      "FARGATE" 
    ],
    "containerDefinitions": [
      {
        "name": "frontend-react-js",
        "image": "number.dkr.ecr.REGION.amazonaws.com/frontend-react-js",
        "essential": true,
        "portMappings": [
          {
            "name": "frontend-react-js",
            "containerPort": 3000,
            "protocol": "tcp", 
            "appProtocol": "http"
          }
        ],
  
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "cruddur",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "frontend-react-js"
          }
        }
      }
    ]
  }
```


create the dockerfile.prod under the frontend-react-js
``` sh
# Base Image ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM node:16.18 AS build

ARG REACT_APP_BACKEND_URL
ARG REACT_APP_AWS_PROJECT_REGION
ARG REACT_APP_AWS_COGNITO_REGION
ARG REACT_APP_AWS_USER_POOLS_ID
ARG REACT_APP_CLIENT_ID

ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
ENV REACT_APP_AWS_PROJECT_REGION=$REACT_APP_AWS_PROJECT_REGION
ENV REACT_APP_AWS_COGNITO_REGION=$REACT_APP_AWS_COGNITO_REGION
ENV REACT_APP_AWS_USER_POOLS_ID=$REACT_APP_AWS_USER_POOLS_ID
ENV REACT_APP_CLIENT_ID=$REACT_APP_CLIENT_ID

COPY . ./frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
RUN npm run build

# New Base Image ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM nginx:1.23.3-alpine

# --from build is coming from the Base Image
COPY --from=build /frontend-react-js/build /usr/share/nginx/html
COPY --from=build /frontend-react-js/nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000
```

create a file called nginx.conf under the frontend-react-js
```sh
# Set the worker processes
worker_processes 1;

# Set the events module
events {
  worker_connections 1024;
}

# Set the http module
http {
  # Set the MIME types
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # Set the log format
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  # Set the access log
  access_log  /var/log/nginx/access.log main;

  # Set the error log
  error_log /var/log/nginx/error.log;

  # Set the server section
  server {
    # Set the listen port
    listen 3000;

    # Set the root directory for the app
    root /usr/share/nginx/html;

    # Set the default file to serve
    index index.html;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to redirecting to index.html
        try_files $uri $uri/ $uri.html /index.html;
    }

    # Set the error page
    error_page  404 /404.html;
    location = /404.html {
      internal;
    }

    # Set the error page for 500 errors
    error_page  500 502 503 504  /50x.html;
    location = /50x.html {
      internal;
    }
  }
}

```

from the folder frontend-react-js run the command to build

```
npm run build
```

run the following command to build the image pointing to the local env 

```
docker build \
--build-arg REACT_APP_BACKEND_URL="https://${CODESPACE_NAME}-4567.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="$AWS_USER_POOLS_ID" \
--build-arg REACT_APP_CLIENT_ID="$APP_CLIENT_ID" \
-t frontend-react-js \
-f Dockerfile.prod \
.

```

To point to the url of the load balancer
```
docker build \
--build-arg REACT_APP_BACKEND_URL="http://cruddur-alb-1044769460.eu-west-2.elb.amazonaws.com:4567" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="$AWS_USER_POOLS_ID" \
--build-arg REACT_APP_CLIENT_ID="$APP_CLIENT_ID" \
-t frontend-react-js \
-f Dockerfile.prod \
.

```


create the repo for the frontend ECR

```
aws ecr create-repository \
  --repository-name frontend-react-js \
  --image-tag-mutability MUTABLE
```


and set the env var

```
export ECR_FRONTEND_REACT_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/frontend-react-js"
echo $ECR_FRONTEND_REACT_URL
```

tag the image

```
docker tag frontend-react-js:latest $ECR_FRONTEND_REACT_URL:latest
```

and we push to the repo in ecr

```
docker push $ECR_FRONTEND_REACT_URL:latest
```


Before pushing, test locallu
```
docker run --rm -p 3000:3000 -it frontend-react-js 

```

create the the task definition for the frontend-react-js

```
{
    "family": "frontend-react-js",
    "executionRoleArn": "arn:aws:iam::238967891447:role/CruddurServiceExecutionRole",
    "taskRoleArn": "arn:aws:iam::238967891447:role/CruddurTaskRole",
    "networkMode": "awsvpc",
    "cpu": "256",
    "memory": "512",
    "requiresCompatibilities": [ 
      "FARGATE" 
    ],
    "containerDefinitions": [
      {
        "name": "frontend-react-js",
        "image": "238967891447.dkr.ecr.eu-west-2.amazonaws.com/frontend-react-jss",
        "essential": true,
        "portMappings": [
          {
            "name": "frontend-react-js",
            "containerPort": 3000,
            "protocol": "tcp", 
            "appProtocol": "http"
          }
        ],
  
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "cruddur",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "frontend-react-js"
          }
        }
      }
    ]
  }
```

and the service-front-react-js.json
```
{
    "cluster": "cruddur",
    "launchType": "FARGATE",
    "desiredCount": 1,
    "enableECSManagedTags": true,
    "enableExecuteCommand": true,
    "loadBalancers": [
      {
          "targetGroupArn": "arn:aws:elasticloadbalancing:eu-west-2:238967891447:targetgroup/cruddur-frontend-react-js/de92d78abee2a37a",
          "containerName": "frontend-react-js",
          "containerPort": 3000
      }
    ],
    "networkConfiguration": {
      "awsvpcConfiguration": {
        "assignPublicIp": "ENABLED",
        "securityGroups": [
            "sg-081fda7fb7464c107"
          ],
          "subnets": [
            "subnet-5d5bd827",
            "subnet-608b5a2c",
            "subnet-4db0f724"
          ]
      }
    },
    "propagateTags": "SERVICE",
    "serviceName": "frontend-react-js",
    "taskDefinition": "frontend-react-js",
    "serviceConnectConfiguration": {
      "enabled": true,
      "namespace": "cruddur",
      "services": [
        {
          "portName": "frontend-react-js",
          "discoveryName": "frontend-react-js",
          "clientAliases": [{"port": 3000}]
        }
      ]
    }
  }
```

```
{
    "cluster": "cruddur",
    "launchType": "FARGATE",
    "desiredCount": 1,
    "enableECSManagedTags": true,
    "enableExecuteCommand": true,
    "loadBalancers": [
      {
          "targetGroupArn": "arn:aws:elasticloadbalancing:eu-west-2:238967891447:targetgroup/cruddur-frontend-react-js/de92d78abee2a37a",
          "containerName": "frontend-react-js",
          "containerPort": 3000
      }
    ],
    "networkConfiguration": {
      "awsvpcConfiguration": {
        "assignPublicIp": "ENABLED",
        "securityGroups": [
            "sg-081fda7fb7464c107"
          ],
          "subnets": [
            "subnet-5d5bd827",
            "subnet-608b5a2c",
            "subnet-4db0f724"
          ]
      }
    },
    "propagateTags": "SERVICE",
    "serviceName": "frontend-react-js",
    "taskDefinition": "frontend-react-js",
    "serviceConnectConfiguration": {
      "enabled": true,
      "namespace": "cruddur",
      "services": [
        {
          "portName": "frontend-react-js",
          "discoveryName": "frontend-react-js",
          "clientAliases": [{"port": 3000}]
        }
      ]
    }
  }
```

before lunch the task definition for the front end

```
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/frontend-react-js.json

```

create the services for the frontend-react-js using the following command

```
aws ecs create-service --cli-input-json file://aws/json/service-frontend-react-js.json

```

Since there is problem with the frontend image, The next step to do is create the image locally (pointing to the local env) and launch it locally

```
docker ps

docker inspect 9175560cb662
```

Note by default bash is not included with busybox and alpie linux

insert this part for the frontend-react-js-json under task-definitions
```
"healthCheck": {
          "command": [
            "CMD-SHELL",
            "curl -f http://localhost:3000 || exit 1"
          ],
          "interval": 30,
          "timeout": 5,
          "retries": 3
        },
```


In our case the problem is the communication between the ALB and the target group. 
You need to able the security group for the port 3000


# Implementation of the SSL and configuration of Domain from Route53

Create the hosted zone for your domain
Once you have created, take note of the "Value/route traffic". it should be something like this
```
ns-207.awsdns-25.com.
ns-1481.awsdns-57.org.
ns-1728.awsdns-24.co.uk.
ns-595.awsdns-10.net.
```

in route53 under domains, go to registered domain.
from name servers (above the DNSSEC status) check if info is the same of the values that if the "Value/route traffic"

To create a SSL/TLS certificate go to AWS Certificate Manager
Go to request and select "Request a public certificate"
Under "fully qualified domain name" insert your domain. for example
example.com
*.example.com
As a validation method, select "DNS validation - raccomended" and as key algorithm select RSA 2048.
Once you have created the certificate request, go to the certificate request and click on create records in route 53.

Note: it takes about a few min to have the status changed from "pending validation" to "issued". but sometimes it could take more than that

Once you have the certification, is time to do some modification on route53 alb and task definition and eventually then repush the images for the backend and frontend

from the hosted zone created before, create 2 new records.

on for example the domain.co.uk and select as a record type "CNAME - routes traffic to another domain name and to some aws resource", toggle on alias and select the endpoint and region. for the routing policy select "simple routing"

do the same thing for the api.domain.co.uk with the same configuration above.

In this way your domain will talk with the alb dns.

the configuration will be the following

![New listener](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/load%20balancer.png)

and set the rules for the https as following

![rule https](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/ruleshttps443.png)


from the task definition of the backend, edit the following line:
```sh
   {"name": "FRONTEND_URL", "value": "https://example.co.uk"},
   {"name": "BACKEND_URL", "value": "https://api.example.co.uk"},
```

once you done, relunch the task definition and recreate the image of the frontend and push it. 


```sh
docker build \
--build-arg REACT_APP_BACKEND_URL="https://example.com" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="$AWS_USER_POOLS_ID" \
--build-arg REACT_APP_CLIENT_ID="$APP_CLIENT_ID" \
-t frontend-react-js \
-f Dockerfile.prod \
.
```

Note: make sure to open the SG of the container backend flask from the SG of the RDS for the port 5432 otherwise you wont be able to use the test script to check the RDS from the container backendflask in ECS.

# Securing Backend flask



In this part of implementation, we need to create 2 docker file. 

one called Dockerfile with the following code which has the debug on
```sh
FROM 238967891447.dkr.ecr.eu-west-2.amazonaws.com/cruddur-python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .



EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567", "--debug"]
```

the other file called Dockerfile.prod with the following code which does not have the debug, the debugger and the reload active.

```sh
FROM 238967891447.dkr.ecr.eu-west-2.amazonaws.com/cruddur-python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .


EXPOSE ${PORT}

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567", "--no-debug", "--no-debugger", "--no-reload"]

```

Make sure to test the docker production changes before pushing the image to the ECR repo.
In our case, we run the docker compose up using the dockerfile rather than recall the build and run process.

Below are the scripts for the building for the backend and frontend

```
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
BUILD_PATH=$(dirname $ABS_PATH)
DOCKER_PATH=$(dirname $BUILD_PATH)
BIN_PATH=$(dirname $DOCKER_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
BACKEND_FLASK_PATH="$PROJECT_PATH/backend-flask"

docker build \
-f "$BACKEND_FLASK_PATH/Dockerfile.prod" \
-t backend-flask-prod \
"$BACKEND_FLASK_PATH/."
```
Note that the REACT_APP_BACKEND_URL should point to your domain instead to your gitpod/codespace
```
#! /usr/bin/bash

docker build \
--build-arg REACT_APP_BACKEND_URL="https://4567-$GITPOD_WORKSPACE_ID.$GITPOD_WORKSPACE_CLUSTER_HOST" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="$AWS_USER_POOLS_ID" \
--build-arg REACT_APP_CLIENT_ID="$APP_CLIENT_ID" \
-t frontend-react-js \
-f Dockerfile.prod \
.
```

and the script to run the image for the backend
```
#! /usr/bin/bash

docker run --rm \
-p 4567:4567 \
--env AWS_ENDPOINT_URL="http://dynamodb-local:8000" \
--env CONNECTION_URL="postgresql://postgres:password@db:5432/cruddur" \
--env FRONTEND_URL="https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}" \
--env BACKEND_URL="https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}" \
--env OTEL_SERVICE_NAME='backend-flask' \
--env OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io" \
--env OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}" \
--env AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
--env AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
--env AWS_XRAY_URL="*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*" \
--env AWS_XRAY_DAEMON_ADDRESS="xray-daemon:2000" \
--env AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
--env ROLLBAR_ACCESS_TOKEN="${ROLLBAR_ACCESS_TOKEN}" \
--env AWS_COGNITO_USER_POOL_ID="${AWS_USER_POOLS_ID}" \
--env AWS_COGNITO_USER_POOL_CLIENT_ID="${APP_CLIENT_ID}" \
-it backend-flask-prod
```


another implementation that we did is to push the image to ecr. create the script under /backend-flask/bin/docker/push/backend-flask-prod

```
#! /usr/bin/bash


ECR_BACKEND_FLASK_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend-flask"
echo $ECR_BACKEND_FLASK_URL

docker tag backend-flask-prod:latest $ECR_BACKEND_FLASK_URL:latest
docker push $ECR_BACKEND_FLASK_URL:latest

```

same for the frontend under ./bin/docker/push/frontend-react-js-prod
```sh
#! /usr/bin/bash


ECR_FRONTEND_REACT_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/frontend-react-js"
echo $ECR_FRONTEND_REACT_URL

docker tag frontend-react-js-prod:latest $ECR_FRONTEND_REACT_URL:latest
docker push $ECR_FRONTEND_REACT_URL:latest
```

We develop also a script that makes it easy the deployment of the ecs backend-flask.
This file is under /bin/ecs/force-deploy-backend-flask

```
#! /usr/bin/bash

CLUSTER_NAME="cruddur"
SERVICE_NAME="backend-flask"
TASK_DEFINTION_FAMILY="backend-flask"


LATEST_TASK_DEFINITION_ARN=$(aws ecs describe-task-definition \
--task-definition $TASK_DEFINTION_FAMILY \
--query 'taskDefinition.taskDefinitionArn' \
--output text)

echo "TASK DEF ARN:"
echo $LATEST_TASK_DEFINITION_ARN

aws ecs update-service \
--cluster $CLUSTER_NAME \
--service $SERVICE_NAME \
--task-definition $LATEST_TASK_DEFINITION_ARN \
--force-new-deployment

#aws ecs describe-services \
#--cluster $CLUSTER_NAME \
#--service $SERVICE_NAME \
#--query 'services[0].deployments' \
#--output table
```

the next implementation is to create the absolute path using the following code for some code of the scripts under the /backend-flask/bin
```
ABS_PATH=$(readlink -f "$0")
BUILD_PATH=$(dirname $ABS_PATH)
DOCKER_PATH=$(dirname $BUILD_PATH)
BIN_PATH=$(dirname $DOCKER_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
echo $PROJECT_PATH

```
the files affected are
/db/schema-load
/db/seed
/db/setup
/docker/build/backend-flask-prod
/docker/build/frontend-react-js-prod

The location of the ./backend-flask/bin has been moved to the previous folder apart for the ./flask/health-check

For any changes of the backend or frontend, do the build tag and push and force the deployment.

# Fixing the Check Auth Token
As you may already know, at the moment the token wont update.
To do this replace the checkAuth.js with the following code

```
import { Auth } from 'aws-amplify';
import { resolvePath } from 'react-router-dom';

export async function getAccessToken(){
  Auth.currentSession()
  .then((cognito_user_session) => {
    const access_token = cognito_user_session.accessToken.jwtToken
    localStorage.setItem("access_token", access_token)
  })
  .catch((err) => console.log(err));
}

export async function checkAuth(setUser){
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((cognito_user) => {
    setUser({
      cognito_user_uuid: cognito_user.attributes.sub,
      display_name: cognito_user.attributes.name,
      handle: cognito_user.attributes.preferred_username
    })
    return Auth.currentSession()
  }).then((cognito_user_session) => {
      localStorage.setItem("access_token", cognito_user_session.accessToken.jwtToken)
  })
  .catch((err) => console.log(err));
};
```

Replace and add the following code for the following file
- rontend-react-js/src/components/MessageForm.js  (the first line of code)
- frontend-react-js/src/pages/HomeFeedPage.js   (the first line of code)
- frontend-react-js/src/pages/MessageGroupNewPage.js   (the first line of code)
- frontend-react-js/src/pages/MessageGroupPage.js   (the first line of code)
- frontend-react-js/src/components/MessageForm.js   (the second line of code)

```
import {checkAuth, getAccessToken} from '../lib/CheckAuth';

import {getAccessToken} from '../lib/CheckAuth';
```


```
  await getAccessToken()
  const access_token = localStorage.getItem("access_token")
```


```
Authorization': `Bearer ${access_token}`
```

# Implementation of Xray on Ecs and Container Insights

on our task definition backend and frontend, add the following part for the xray
```
{
      "name": "xray",
      "image": "public.ecr.aws/xray/aws-xray-daemon" ,
      "essential": true,
      "user": "1337",
      "portMappings": [
        {
          "name": "xray",
          "containerPort": 2000,
          "protocol": "udp"
        }
      ]
    },
```

create the script to create the new task definition
on the folder aws-bootcamp-cruddur-2023/bin/backend create a file called register.
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
FRONTEND_PATH=$(dirname $ABS_PATH)
BIN_PATH=$(dirname $FRONTEND_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
TASK_DEF_PATH="$PROJECT_PATH/aws/task-definitions/backend-flask.json"

echo $TASK_DEF_PATH

aws ecs register-task-definition \
--cli-input-json "file://$TASK_DEF_PATH"
```

do the same thing for the frontend
on the folder aws-bootcamp-cruddur-2023/bin/frontend create a file called register.

```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
BACKEND_PATH=$(dirname $ABS_PATH)
BIN_PATH=$(dirname $BACKEND_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
TASK_DEF_PATH="$PROJECT_PATH/aws/task-definitions/frontend-react-js.json"

echo $TASK_DEF_PATH

aws ecs register-task-definition \
--cli-input-json "file://$TASK_DEF_PATH"
```

on the folder aws-bootcamp-cruddur-2023/bin/backend create a file called run.
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
BACKEND_PATH=$(dirname $ABS_PATH)
BIN_PATH=$(dirname $BACKEND_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
ENVFILE_PATH="$PROJECT_PATH/backend-flask.env"

docker run --rm \
--env-file $ENVFILE_PATH \
--network cruddur-net \
--publish 4567:4567 \
-it backend-flask-prod

```
NOTE:
add the  /bin/bash after the -it backend-flask-prod if you want to shell inside the contianer.

on the folder aws-bootcamp-cruddur-2023/bin/frontend create a file called run.
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
FRONTEND_PATH=$(dirname $ABS_PATH)
BIN_PATH=$(dirname $FRONTEND_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
ENVFILE_PATH="$PROJECT_PATH/frontend-react-js.env"

docker run --rm \
--env-file $ENVFILE_PATH \
--network cruddur-net \
--publish 3000:3000 \
-it frontend-react-js-prod

```

change the code of the docker-compose-gitpod.yml of the backend

```
environment:
      AWS_ENDPOINT_URL: "http://dynamodb-local:8000"
      #CONNECTION_URL: "${PROD_CONNECTION_URL}"
      CONNECTION_URL: "postgresql://postgres:password@db:5432/cruddur"
      #FRONTEND_URL: "https://${CODESPACE_NAME}-3000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
      #BACKEND_URL: "https://${CODESPACE_NAME}-4567.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      OTEL_SERVICE_NAME: 'backend-flask'
      OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
      OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
      AWS_DEFAULT_REGION: "${AWS_DEFAULT_REGION}"
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
      #AWS_XRAY_URL: "*${CODESPACE_NAME}-4567.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}*"
      AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      ROLLBAR_ACCESS_TOKEN: "${ROLLBAR_ACCESS_TOKEN}"
      #env var for jwttoken
      AWS_COGNITO_USER_POOL_ID: "${AWS_USER_POOLS_ID}"
      AWS_COGNITO_USER_POOL_CLIENT_ID: "${APP_CLIENT_ID}"
```

with the following code
```
  env_file:
      - backend-flask.env
```

same thing for the frontend

```sh
environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      #REACT_APP_BACKEND_URL: "https://${CODESPACE_NAME}-4567.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
      REACT_APP_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}"
      #REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID: ""
      REACT_APP_AWS_COGNITO_REGION: "${AWS_DEFAULT_REGION}"
      REACT_APP_AWS_USER_POOLS_ID: "${AWS_USER_POOLS_ID}"
      REACT_APP_CLIENT_ID: "${APP_CLIENT_ID}"
```

with the following code

```sh
  env_file:
      - frontend-react-js.env
```

Since the file env does not pass the value of the env var, there is additional implementation that needs to be done.

create a file generate-env-gitpod under the aws-bootcamp-cruddur-2023/bin/backend

and paste the following code
```
#! /usr/bin/env ruby

require 'erb'

template = File.read 'erb/backend-flask-gitpod.env.erb'
content = ERB.new(template).result(binding)
filename = "backend-flask.env"
File.write(filename, content)

```


create a file generate-env-gitpod under the aws-bootcamp-cruddur-2023/bin/frontend

and paste the following code
```
#! /usr/bin/env ruby

require 'erb'

template = File.read 'erb/frontend-react-js-gitpod.env.erb'
content = ERB.new(template).result(binding)
filename = "frontend-react-js.env"
File.write(filename, content)

```

create  a folder called erb and create the following file backend-flask-gitpod.env.erb under erb folder


```sh
AWS_ENDPOINT_URL=http://dynamodb-local:8000
CONNECTION_URL=postgresql://postgres:password@db:5432/cruddur
FRONTEND_URL=https://3000-<%= ENV['GITPOD_WORKSPACE_ID'] %>.<%= ENV['GITPOD_WORKSPACE_CLUSTER_HOST'] %>
BACKEND_URL=https://4567-<%= ENV['GITPOD_WORKSPACE_ID'] %>.<%= ENV['GITPOD_WORKSPACE_CLUSTER_HOST'] %>
OTEL_SERVICE_NAME=backend-flask
OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io
OTEL_EXPORTER_OTLP_HEADERS=x-honeycomb-team=<%= ENV['HONEYCOMB_API_KEY'] %>
AWS_XRAY_URL=*4567-<%= ENV['GITPOD_WORKSPACE_ID'] %>.<%= ENV['GITPOD_WORKSPACE_CLUSTER_HOST'] %>*
AWS_XRAY_DAEMON_ADDRESS=xray-daemon:2000
AWS_DEFAULT_REGION=<%= ENV['AWS_DEFAULT_REGION'] %>
AWS_ACCESS_KEY_ID=<%= ENV['AWS_ACCESS_KEY_ID'] %>
AWS_SECRET_ACCESS_KEY=<%= ENV['AWS_SECRET_ACCESS_KEY'] %>
ROLLBAR_ACCESS_TOKEN=<%= ENV['ROLLBAR_ACCESS_TOKEN'] %>
AWS_COGNITO_USER_POOL_ID=<%= ENV['AWS_USER_POOLS_ID'] %>
AWS_COGNITO_USER_POOL_CLIENT_ID=<%= ENV['APP_CLIENT_ID'] %>

```

create  a folder called erb and create the following file frontend-react-js-gitpod.env.erb 

```sh
REACT_APP_BACKEND_URL=https://4567-<%= ENV['GITPOD_WORKSPACE_ID'] %>.<%= ENV['GITPOD_WORKSPACE_CLUSTER_HOST'] %>
REACT_APP_AWS_PROJECT_REGION=<%= ENV['AWS_DEFAULT_REGION'] %>
REACT_APP_AWS_COGNITO_REGION=<%= ENV['AWS_DEFAULT_REGION'] %>
REACT_APP_AWS_USER_POOLS_ID=<%= ENV['AWS_USER_POOLS_ID'] %>
REACT_APP_CLIENT_ID=<%= ENV['APP_CLIENT_ID'] %>
```

from the gitpod.yml add the scripts to create the files env necessary for the backend and frontend dockers.
```
  source  "$THEIA_WORKSPACE_ROOT/bin/backend/generate-env-gitpod"
  source  "$THEIA_WORKSPACE_ROOT/bin/frontend/generate-env-gitpod
```


In this part of the implementation, we link all the containers to connect with a specific network.
change the configuration of your docker-compose.yml
```
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```
with the following code

```
networks: 
  cruddur-net:
    driver: bridge
    name: cruddur-net
```

and for each services, make sure to attach the crudduer-net network by adding the following code
```
  networks:
      - cruddur-net
```

to troublshoot, you can use a busy box.
create a file under aws-bootcamp-cruddur-2023/bin called busybox
and paste the following code
```
#! /usr/bin/bash

docker run --rm \
  --network cruddur-net \
  -p 4567:4567 \
  -it busybox
```

also we can add some tools such as ping on our dockerfile.prod
after url of the image. this is for the debugging

```
RUN apt-get update -y
RUN apt-get install iputils-ping -y
```
# Enable Container Insights

To enable this function, go to the cluster and click on update cluster.

Under the section Monitoring, toggle on Use Container Insights













### Reference
![Ashish Video Cloud Security Podcast](https://www.youtube.com/watch?v=zz2FQAk1I28&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=58)

![Ashish Video Cloud Security Podcast](https://www.youtube.com/watch?v=MzVCEViI8Gg&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=70)