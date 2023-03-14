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