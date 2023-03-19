# Week 4 — Postgres and RDS

This week the team will be talking about Database in particular RDS

# Security in RDS

RDS is a relational database. this means is composed of multiple tables and rows. This differs from the none relational database which has 1 table and the structure is not fixed.

## Best practice in AWS and application

- Make sure to create the database in the region as it should be compliant with the local law. For example, due to the GDPR, database can not be outside the EU
- Another best practice is to set the encryption on your database.
- The database should not be publicly accessible.
- Must enable deletion protection for unintentional deletion.
- Must be available amazon organization with the SCP put in place.
- Active cloudtrail for auditing purposes and guard duty
- Set on the SG only to the ip for dev/admin so they can access the instance. **Do not put 0.0.0.0/0** 
- Delete the database if not in use.
- Use a secret manager to manage the user/password access for the db
- Encryption in transit and at rest
- Limit the operation of the users.
- Authentication using IAM or Kerberos.

# Create RDS

from the terminal post the following command to create the RDS Instance
```
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username root \
  --master-user-password huEE33z2Qvl383 \
  --allocated-storage 20 \
  --availability-zone eu-west-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp3 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```
Note:
- For the availability zone check the console so the everything match according on where you are working
-

Once the rds is running, make sure to put it in stop so you dont incure with extra cost. Note that this is valid only for 7 days so it is not permanent.

from the terminal type the following code
```
psql -Upostgres --host localhost
```

**Common Psql commands**
```
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```

# create local database 

Type the following command to create the database within the PSQL client
```
CREATE database cruddur;
```

from backend flask, create a folder called db and inside a file called schema.sql

and insert the following sql command on the schema.sql created before
```
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```
exit from the psql command by typing the following command
```
\q
```
and type the following command
```
psql cruddur < backend-flask/db/schema.sql -h localhost -U postgres
```
and type the password and type the following command to create the env var
```
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```
do the same steps for the rds (not necessary at this point unless you start connecting with the rds)

from backend-flask create a folder call bin and inside create 3 files called"db-create" "db-drop" and "db-schema-load" and inside for each file created, insert the following command
```
#! /usr/bin/bash
```

to change the executable of the file created before, type the following code:
```
chmod u+x bin/db-create
chmod u+x bin/db-drop
chmod u+x bin/db-schema-load
```

from the file db-drop add the following code
```
echo "db-drop"
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
```
For more information about sed visit the following [link](https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/)

from the file db-create add the following command
```
echo "db-create"
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"

```

from the file db-schema-load add the following command
```
#echo "== db-schema-load"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"

echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```

for the coloring the echo refer to the following [link](https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux)

 on schema.sql insert the code to create the table users and table activities
 ```

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text,
  handle text,
  cognito_user_id text,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID not null,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
 ```

 create a script inside the folder bin called **db-connect** 
 ```
#! /usr/bin/bash

psql $CONNECTION_URL
 ```

and change the permission of the file
 ```
chmod u+x bin/db-connection
 ```

 create a file on db called seed.sql and create inside bin a file called db-seed with following code
 ```
#! /usr/bin/bash
#echo "== db-seed-load"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"

echo $seed_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
 ```


and on the seed.sql insert this code
```
-- this file was manually created
INSERT INTO public.users (display_name, handle, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown' ,'MOCK'),
  ('Andrew Bayko', 'bayko' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
```

# Creation connection with RDS

If you have stopped and rerun you gitpod/codespace enviroment, make sure to rerun the **db-create**, **db-schema-load** and **db-seed** in the order mention before running the db-connect. Make sure the containers are up and running first before making the connection!
There will be an instruction later how to implement the automazation once you launch the CDE enviroment without launching.

**How to see the connection**

create a file called **db-sessions** under backend-flask/bin 
```
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

changed the permission of the file:
```
 chmod u+x ./db-sessions
```


create a file called **db-setup** under backend-flask/bin 

```
#! /usr/bin/bash

-e # stop if it fails at any point
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"

```

changed the permission of the file:
```
 chmod u+x ./db-setup
```

## Install driver for psql

Add the following libraries into the requirements.txt of the backend flask
```
psycopg[binary]
psycopg[pool]
```

and run the for this time the following command:
```
pip install -r requirements.txt
```

create a file under lib called **db.py**. this will be the connection for your backend
```
from psycopg_pool import ConnectionPool
import os

def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)

  '''

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)
```

and insert the library on **home_activities**
```
from lib.db import pool,query_wrap_array
```

and add the following code
```
sql = """
      SELECT
        activities.uuid,
        users.display_name,
        users.handle,
        activities.message,
        activities.replies_count,
        activities.reposts_count,
        activities.likes_count,
        activities.reply_to_activity_uuid,
        activities.expires_at,
        activities.created_at
      FROM public.activities
      LEFT JOIN public.users ON users.uuid = activities.user_uuid
      ORDER BY activities.created_at DESC
      """
      print(sql)
      span.set_attribute("app.result_length", len(results))
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
          # this will return a tuple
          # the first field being the data
          json = cur.fetchall()
      return json[0]
```

from the file docker-compose change the **CONNECTIONS_URL** with the following
```
      CONNECTION_URL: "postgresql://postgres:password@db:5432/cruddur"
```

From the console active the RDS if it is in pause mode

create the PROD_CONNECTION_URL that will point to the RDS
```
postgresql://nameofthedb:masterpassword@endpointofthedb:5432/cruddur
```
create the local env and on gitpod/codespace
```
export PROD_CONNECTION_URL="postgresql://nameofthedb:masterpassword@endpointofthedb:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://nameofthedb:masterpassword@endpointofthedb:5432/cruddur"
```
note: the password should not ending with ! as the url will be !@ and it could cause some error during the launching the command. if you experience an error "bash bla bla cruddur" you need to change the password for the DB of rds 

In order to connect to the RDS instance we need to provide our Gitpod IP and whitelist for inbound traffic on port 5432.

export GITPOD_IP=$(curl ifconfig.me)

create the env var for the security group and the security group rule
```
export DB_SG_ID="sg-sdfsdf"
gp env DB_SG_ID="sg-sdfsdf"
export DB_SG_RULE_ID="sgr-sdfsdfsdf"
gp env DB_SG_RULE_ID="sgr-sdfsdfsdf"
```

Since the ip address changes everytime, you need to change the ip on the security group of the rds instance
here is the script to add to the file**rds-update-sg-rule** under bin
```
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

on the file *gitpod.yml** add this line so it will get the ip of the instance
```
    command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source  "$THEIA_WORKSPACE_ROOT/backend-flask/bin/rds-update-sg-rule"
```

# Create Lambda
Create a lambda in the region where are your services and create the same file under aws/lambdas calling the file cruddur-post-confirmation.py

```
import json
import psycopg2

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)
    user_display_name = user['name']
    user_email        = user['email']
    user_handle       = user['preferred_username']
    user_cognito_id   = user['sub']
    try:
        conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
        cur = conn.cursor()
        sql = f"""
            "INSERT INTO users (
                display_name,
                email,
                handle,
                cognito_user_id
            ) 
            VALUES(
                {user_display_name},
                {user_email},
                {user_handle},
                {user_cognito_id}
            )"
        """            
        cur.execute(sql)
        conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            cur.close()
            conn.close()
            print('Database connection closed.')

    return event
```

the env var for the lambda will be **CONNECTION_URL** which has the variable of the **PROD_CONNECTION_URL** set on gitpod/codespace (example: PROD_CONNECTION_URL="postgresql://nameofthedb:masterpassword@endpointofthedb:5432/cruddur)

Once you create the env var, create also the layer>add layers> select specify arn
```
arn:aws:lambda:your region:898466741470:layer:psycopg2-py38:1
```

now it is time to create the trigger for cognito.
from cognito,  select the user pool and go to the user pool properties to find the lambda triggers. follow the configuration according to the image below:

![lambda triggers](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/lambda%20triggers.png)

#Troubleshooting

This command see if the connection is estabilished
```
echo $CONNECTION_URL
```