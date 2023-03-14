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

