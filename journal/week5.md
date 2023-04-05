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

# Cost
This Week Cirag did not post any video about cost so I did some research.

## DynamoDB
The pricing for dynamo db are in 2 flavours:

**Pricing for on demand capacity mode**: Amazon will charge you depeding of your data read and write of your application performs on your table.

Few cases are:
- Create new table with unknown workloads
- Have unpredictable application traffic
- Prefer the ease of pay as you go 

- **Pricing for for provisioned capacity mode**: You need to specify the number of reads and writes per second that your application needs.

Few Cases are:
- Have a predictable application traffic
- Run application whose traffic is consistant or ramps gradually
- Can forcast capacity requirements to control cost.

Dynamo db is always free.
The 25 read and write capacity are free
The first 25GB are free
The 2.5 million DynamoDB Streams read request are free
 [Resource](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all&all-free-tier.q=dynamo%2Bdb&all-free-tier.q_operator=AND)

## Gateway Endpoint
As in our implementation, Lambda needs to connect with DynamoDB, we need to use Gateway endpoint.
On amazon web service documentations, it says there is no additional charge. [Resource](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html)

## Lambda
Since we are going to use Lambda in our application to write to the DynamoDB, this service is always free up to a certain limit.

The first 1 million invocations per month are free and up to 3.2million seconds of compute time per month [resource](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all&all-free-tier.q=lambda&all-free-tier.q_operator=AND)


# Implementations

## Implementation Dynamo Data Stream

Create the table using the script. This will create the dynamodb in your aws account. 
```
/bin/ddb/schema-load prod
```
Note: If you returns the error **table already exists: cruddur-messages**, thats mean the table is already created into your account. if you dont se the table, make sure you are in the right region.

The next steps is to create the endpoint.
To do please follow the follwing [link](https://scribehow.com/shared/Amazon_Workflow__9knsACwST_equLV8dYYa9A).





Reference
- Contino.Io
- AWS Documentation
- ![Ashish Video Cloud Security Podcast](https://www.youtube.com/watch?v=gFPljPNnK2Q&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=51)
