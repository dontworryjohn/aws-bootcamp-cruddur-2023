#!/user/bin/env bash

# upgrade npm and install frontend
cd frontend-react-js && npm update -g && npm install;

# backend pip requirements

cd /workspaces/aws-bootcamp-cruddur-2023/backend-flask && pip3 install -r requirements.txt;

# postgresql
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-client-13 libpq-dev 

#set ip for security group to connect with the gitpod/codespace
source  "/workspaces/aws-bootcamp-cruddur-2023/bin/rds/update-sg-rule"

#Fargate session
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin
cd /workspaces/aws-bootcamp-cruddur-2023/backend-flask

#install sam 
cd /workspaces
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
cd /workspaces/aws-bootcamp-cruddur-2023/


#ECR Login
source  "/workspaces/aws-bootcamp-cruddur-2023/bin/ecr/login"

#Create Env for codespace
ruby "/workspaces/aws-bootcamp-cruddur-2023/bin/backend/generate-env-codespace"
ruby "/workspaces/aws-bootcamp-cruddur-2023/bin/frontend/generate-env-codespace"

#CDK
cd /workspaces/aws-bootcamp-cruddur-2023/thumbing-serverless-cdk && cp .env.example .env && npm i && npm install aws-cdk -g;

#Install Sharp and ClientS3
cd /workspaces/aws-bootcamp-cruddur-2023/aws/lambdas/process-images && npm i sharp && npm i @aws-sdk/client-s3;

#CFN
pip install cfn-lint && cargo install cfn-guard && gem install cfn-toml