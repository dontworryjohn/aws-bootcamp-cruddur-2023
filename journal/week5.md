# Week 5 — DynamoDB and Serverless Caching

This week the team will be talking about DynamoDB.

# Security in DynamoDB

DynamoDB is a None Relational Database and is used for high performace applications at any scale.

Below some uses cases of DynamoDB:

![DynamoDB use cases](
https://cdn.sanity.io/images/hgftikht/production/f9381ef455f0c2a07601a6b55113c44e1acae538-2060x1150.png?w=1920&h=1072&fit=crop&fm=webp)


How to access DynamoDB

![DynamoDB via Internet Gateway](https://docs.aws.amazon.com/images/amazondynamodb/latest/developerguide/images/ddb-no-vpc-endpoint.png)


![DynamoDB via Internet Gateway](https://docs.aws.amazon.com/images/vpc/latest/privatelink/images/without-gateway-endpoints.png)

In these 2 diagrams, the communication with dynamodb goes outside the aws through the internet and reaches dynamodb endpoint. This is not a good  practice first for a security prospective and second for a cost prospective.

![DynamoDB via VPC ENDPOINT](https://docs.aws.amazon.com/images/amazondynamodb/latest/developerguide/images/ddb-yes-vpc-endpoint.png)

[DynamoDB vi GATEWAY ENDPOINT](https://docs.aws.amazon.com/images/vpc/latest/privatelink/images/gateway-endpoints.png)





Reference
- Contino.Io
- AWS Documentation