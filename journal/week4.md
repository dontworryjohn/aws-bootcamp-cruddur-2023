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
- Authentication using IAM or Kerberos,

