# Week 5 — DynamoDB and Serverless Caching

This week the team will be talking about DynamoDB.

# Security in DynamoDB

DynamoDB is a None Relational Database and is used for high performace applications at any scale.

Below some use cases of DynamoDB:

![DynamoDB use cases](
https://cdn.sanity.io/images/hgftikht/production/f9381ef455f0c2a07601a6b55113c44e1acae538-2060x1150.png?w=1920&h=1072&fit=crop&fm=webp)


How to access DynamoDB

![DynamoDB via Internet Gateway](https://docs.aws.amazon.com/images/amazondynamodb/latest/developerguide/images/ddb-no-vpc-endpoint.png)


![DynamoDB via Internet Gateway](https://docs.aws.amazon.com/images/vpc/latest/privatelink/images/without-gateway-endpoints.png)

In these 2 diagrams, the communication with dynamodb goes outside the aws through the internet and reaches dynamodb endpoint. This is not a good practice first from a security and costs perspective.

![DynamoDB via VPC ENDPOINT](https://docs.aws.amazon.com/images/amazondynamodb/latest/developerguide/images/ddb-yes-vpc-endpoint.png)

![DynamoDB vi GATEWAY ENDPOINT](https://docs.aws.amazon.com/images/vpc/latest/privatelink/images/gateway-endpoints.png)

In these 2 diagrams, the communication with dyanomodb is within the aws network and not through the public internet.

## Best Practice

### Aws Prospective
- Use VPC Endpoint to create a private connection from your application to the dynamodb. This helps prevent unauthorised access  to your instance from public internet
- Compliance Standard
- Dynamodb should only be in the AWS region that you are legally allowed to be holding user data in.
- Amazon Organization SCP to manage permission to do the operation
- AWS Cloudtrail helps to monitor and trigger alerts on malicious DyanmoDB behaviour.
- AWS Config Rule (Regional Service)

### Application Prospective
- Dynamo DB to use appropriate Authentication such as IAM Roles or AWS Cognito Identity Pool (Temporary credentials) rather than permanent credential such as IAM users or group
- Dyanomodb User Lifecycle Management
- AWS IAM role instead of individual users to access and manage dynamodb
 DAX Service (IAM) role to have read-only access to dynamodb
 - Do not access dynamodb through the internet, use site-to-site or Direct Connect to access dynamodb from the on-premise.
 - Client Side encryption for sensitive information on dynamodb (recommended by amazon)


# Implementations





Reference
- Contino.Io
- AWS Documentation
![Ashish Video Cloud Security Podcast]()
