#!/user/bin/env bash

# upgrade npm and install frontend
cd frontend-react-js && npm update -g && npm install;

# backend pip requirements

cd backend-flask && pip3 install -r requirements.txt;

# postgresql
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-client-13 libpq-dev 

#set ip for security group to connect with the gitpod/codespace
source  "/workspaces/aws-bootcamp-cruddur-2023/backend-flask/bin/rds/update-sg-rule"

