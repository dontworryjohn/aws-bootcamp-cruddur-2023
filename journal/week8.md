# Week 8 — Serverless Image Processing

This week the team will be talking about CDK

# CDK

In this section, it will be illustraded the steps to create a cdk project.

Before launching the CDK, you need to boostrap

Bootstrapping is the process of provisioning resources for the AWS CDK before you can deploy AWS CDK apps into an AWS environment.

If you launch in serveral region, you need to bootstrap for each region that you need.

Follow you find the command to boostrapping in a specific region

```sh
cdk bootstrap "aws://ACCOUNTNUMBER/REGION"
```

Example:
```sh
for a single region
cdk bootstrap "aws://123456789012/us-east-1"

for a multiple region
cdk bootstrap 123456789012/us-east-1 123456789012/us-west-1
```

Create the folder: In our case **thumbing-serverless-cdk**

Move into the folder and run  **npm install aws-cdk -g**  to install(-g stands for global). This command installs the AWS Cloud Development Kit (CDK) globally on your dev env using the Node.js package manager (npm)

To initialise the project type **cdk init app --language typescript**  (instead of typescript, you can choose another language supported by cdk such JavaScript, TypeScript, Python, Java, C#)

To work with the cdkfile, go to the file inside the lib/thumbing-serverless-cdk-stack.ts

To define the s3 buckeet do the following:

import the library for s3 

```sh
import * as s3 from 'aws-cdk-lib/aws-s3';
```

set the variable (Since this project in typescript which is strongly typed. it means all must have  a specific data type)
```sh
const bucketName: string = process.env.THUMBING_BUCKET_NAME as string;
const bucket = this.createBucket(bucketName);
```

with the following code, cdk creates the s3 bucket

```sh
 createBucket(bucketName: string): s3.IBucket{
    const bucket = new s3.Bucket(this, 'ThumbingBucket', {
      bucketName: bucketName,
      removalPolicy: cdk.RemovalPolicy.DESTROY
    });
    return bucket;
```

To launch the AWS CloudFormation template based on the AWS CDK, type:
```sh
cdk synth
```
**Note** 
- if you run again the code, the folder cdk.out will be updated.
- this is a good way to troubleshooting and see what resources have been created before deploying.

the output will be something like
```sh
Resources:
  ThumbingBucket715A2537:
    Type: AWS::S3::Bucket
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/ThumbingBucket/Resource
  CDKMetadata:
    Type: AWS::CDK::Metadata
    Properties:
      Analytics: v2:deflate64:H4sIAAAAAAAA/zPSMzfXM1BMLC/WTU7J1s3JTNKrDi5JTM7WAQrFFxvrVTuVJmenlug4p+VBWLUgZlBqcX5pUXIqiO2cn5eSWZKZn1erk5efkqqXVaxfZmihZ2gKNDerODNTt6g0ryQzN1UvCEIDAKbhjuNzAAAA
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/CDKMetadata/Default
    Condition: CDKMetadataAvailable
Conditions:
  CDKMetadataAvailable:
    Fn::Or:
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - af-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-northeast-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-northeast-2
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-southeast-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-southeast-2
          - Fn::Equals:
              - Ref: AWS::Region
              - ca-central-1
          - Fn::Equals:
              - Ref: AWS::Region
              - cn-north-1
          - Fn::Equals:
              - Ref: AWS::Region
              - cn-northwest-1
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-central-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-north-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-2
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-3
          - Fn::Equals:
              - Ref: AWS::Region
              - me-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - sa-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-east-2
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - us-west-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-west-2
Parameters:
  BootstrapVersion:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /cdk-bootstrap/hnb659fds/version
    Description: Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]
Rules:
  CheckBootstrapVersion:
    Assertions:
      - Assert:
          Fn::Not:
            - Fn::Contains:
                - - "1"
                  - "2"
                  - "3"
                  - "4"
                  - "5"
                - Ref: BootstrapVersion
        AssertDescription: CDK bootstrap stack version 6 required. Please run 'cdk bootstrap' with a recent version of the CDK CLI.

```

**Note**
You can deploy your stack and add new resources on top. The only issue is with Dynamodb when you start rename it and there are some data on it. this could delete the dynamodb resource.



To deploy the CDK project launch the following code. then check it on cloudformation

```sh
cdk deploy
```
**Note**
Before deploying, CDK launch a synth to check if the code is correct.


The next step is to add lambda in our stack.

You need to import the lambda from the cdk library and the dotenv library
```sh
import * as lambda from 'aws-cdk-lib/aws-lambda'
import * as dotenv from 'dotenv';
```

from the folder, run the following command to install the dotenv dependency to import the file .env
```sh
 npm i dotenv

```

set the variables for the lambda
```sh
const functionPath: string = process.env.THUMBING_FUNCTION_PATH as string;
const folderInput: string = process.env.THUMBING_S3_FOLDER_INPUT as string;
const folderOutput: string = process.env.THUMBING_S3_FOLDER_OUTPUT as string;
const lambda = this.createLambda(functionPath, bucketName, folderInput, folderOutput)
```

and then we create the lambda function

```sh
   createLambda(functionPath: string, bucketName: string, folderInput: string, folderOutput: string): lambda.IFunction{
    const lambdaFunction = new lambda.Function(this, 'thumbLambda', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(functionPath),
      environment: {
        DEST_BUCKET_NAME: bucketName,
        FOLDER_INPUT: folderInput,
        FOLDER_OUTPUT: folderOutput,
        PROCESS_WIDTH: '512',
        PROCESS_HEIGHT: '512'
      }
    });
    return lambdaFunction;
  }
  ```
**Note**
Lambda function needs atleast 3 parameters Runtime (languague of the code), handler and code (which is the source where is localted our code)

create the .env with the following info
```sh
THUMBING_BUCKET_NAME="cruddur-thumbs238967891447"
THUMBING_FUNCTION_PATH="/workspace/aws-bootcamp-cruddur-2023/aws/lambdas"
THUMBING_S3_FOLDER_INPUT="avatar/original"
THUMBING_S3_FOLDER_OUTPUT="avatar/processed"

```
**Note** The THUMBING_BUCKET_NAME must be unique as the bucket must be unique in all aws accounts.

if you launch the **cdk synth** the result will be:

```sh
Resources:
  ThumbingBucket715A2537:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: cruddur-thumbs238967891447
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/ThumbingBucket/Resource
  thumbLambdaServiceRole961849F1:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: sts:AssumeRole
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: "2012-10-17"
      ManagedPolicyArns:
        - Fn::Join:
            - ""
            - - "arn:"
              - Ref: AWS::Partition
              - :iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/thumbLambda/ServiceRole/Resource
  thumbLambda4F6A0672:
    Type: AWS::Lambda::Function
    Properties:
      Code:
        S3Bucket:
          Fn::Sub: cdk-hnb659fds-assets-${AWS::AccountId}-${AWS::Region}
        S3Key: 588501aa2768cc632a54d601ec8aba2f92d456544b8dcea5b638ef8bbcaab1d3.zip
      Role:
        Fn::GetAtt:
          - thumbLambdaServiceRole961849F1
          - Arn
      Environment:
        Variables:
          DEST_BUCKET_NAME: cruddur-thumbs238967891447
          FOLDER_INPUT: avatar/original
          FOLDER_OUTPUT: avatar/processed
          PROCESS_WIDTH: "512"
          PROCESS_HEIGHT: "512"
      Handler: index.handler
      Runtime: nodejs18.x
    DependsOn:
      - thumbLambdaServiceRole961849F1
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/thumbLambda/Resource
      aws:asset:path: asset.588501aa2768cc632a54d601ec8aba2f92d456544b8dcea5b638ef8bbcaab1d3
      aws:asset:is-bundled: false
      aws:asset:property: Code
  CDKMetadata:
    Type: AWS::CDK::Metadata
    Properties:
      Analytics: v2:deflate64:H4sIAAAAAAAA/zWOSw6DMAxEz9J9cEtRRbcFqQegB0AhuMh8Egkn7SLK3ZtAWb3xeOTxFcoSLif55Uz1UzZTB/5lpZpEtFrPBfjKqQmtqN/6r3ZUkjGIWS5dL8E/nVaWjE6xQwdBcgHfmBmTnRgEF61kRsvwSAiiQTZuVSi2OXYPpIctfyyiro3uab+pTY8w8vmT3yG/xd9HJspWpy0tCM3OH2DX5PLXAAAA
    Metadata:
      aws:cdk:path: ThumbingServerlessCdkStack/CDKMetadata/Default
    Condition: CDKMetadataAvailable
Conditions:
  CDKMetadataAvailable:
    Fn::Or:
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - af-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-northeast-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-northeast-2
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-southeast-1
          - Fn::Equals:
              - Ref: AWS::Region
              - ap-southeast-2
          - Fn::Equals:
              - Ref: AWS::Region
              - ca-central-1
          - Fn::Equals:
              - Ref: AWS::Region
              - cn-north-1
          - Fn::Equals:
              - Ref: AWS::Region
              - cn-northwest-1
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-central-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-north-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-1
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-2
          - Fn::Equals:
              - Ref: AWS::Region
              - eu-west-3
          - Fn::Equals:
              - Ref: AWS::Region
              - me-south-1
          - Fn::Equals:
              - Ref: AWS::Region
              - sa-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-east-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-east-2
      - Fn::Or:
          - Fn::Equals:
              - Ref: AWS::Region
              - us-west-1
          - Fn::Equals:
              - Ref: AWS::Region
              - us-west-2
Parameters:
  BootstrapVersion:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /cdk-bootstrap/hnb659fds/version
    Description: Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]
Rules:
  CheckBootstrapVersion:
    Assertions:
      - Assert:
          Fn::Not:
            - Fn::Contains:
                - - "1"
                  - "2"
                  - "3"
                  - "4"
                  - "5"
                - Ref: BootstrapVersion
        AssertDescription: CDK bootstrap stack version 6 required. Please run 'cdk bootstrap' with a recent version of the CDK CLI.
```