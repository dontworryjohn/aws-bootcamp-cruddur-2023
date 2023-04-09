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
#FROM 238967891447.dkr.ecr.eu-west-2.amazonaws.com/cruddur-python

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


****************** to start here
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
  --port 80 \
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
        "sg-04ca5ebd69e0aec6f"
      ],
      "subnets": [
        "subnet-0462b87709683ccaa",
        "subnet-066a53dd88d557e05",
        "subnet-021a6adafb79249e3"
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
    echo "No TASK_ID argument supplied eg ./bin/ecs/connect-to service TASKNUMBER backend-flask"
    exit 1
fi
TASK_ID=$1

if [ -z "$2" ]; then
    echo "No CONTAINER_NAME argument supplied eg ./bin/ecs/connect-to service TASKNUMBER backend-flask"
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







Reference
![Ashish Video Cloud Security Podcast](https://www.youtube.com/watch?v=zz2FQAk1I28&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=58)
