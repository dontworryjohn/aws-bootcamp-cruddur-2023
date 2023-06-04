# Week 8 — Serverless Image Processing

This week the team will be talking about CDK
- [Cost](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#cost)
- [CDK](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#cdk)
- [Cloudfront Network Distribution](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#cloudfront-network-distribution)
- [Implementation User Profile Page](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#implementation-user-profile-page)
- [Implementation of Migration Backend Endpoint](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#implementation-of-migration-backend-endpoint-and-profile-form)
- [Implementation Avatar Uploading](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#implementation-avatar-uploading)
- [Rendering Avatar using Cloudfront](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week8.md#rendering-avatar-using-cloudfront)

# Cost

In terms of cost, CDK does not charge for the usage of the service. You only pay for the resources created in the AWS CDK.

Please see below the resources used:

- S3: Free for the first 12 months. AWS gives 5GB storage, 20,000 Get Requests and 2,000 Put Requests

- Lambda: Always free. AWS gives 1 million free requests per month and up to 3.2 million seconds of compute time per month.

- Api Gateway: Free for the first 12 months. AWS gives million API calls received per month.

- Amazon Cloudwatch: Always Free. 10 Custom Metrics and alarms, 1.000.000 API Requests,5GB of Log Data Ingestion and 5GB of Log Data Archive, 3 Dashboards with up to 50 Metrics Each per Month

- Cloudfront: Always Free. AWS provides with 1 TB of data transfer out per month, 10.000.000 HTTP or HTTPS Requests per month, 2.000.000 CloudFront Function invocations per month.

- SNS: Always Free. AWS offers 1.000.000 Publishes, 100.000 HTTP/S Deliveries and 1.000 Email Deliveries

# CDK
This section will illustrate the steps to create a CDK project.

Before launching the CDK, you need to boostrap

Bootstrapping is the process of provisioning resources for the AWS CDK before you can deploy AWS CDK apps into an AWS environment.

If you launch in several regions, you need to bootstrap for each region that you need.

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

From gitpod.yml add these lines of code. This automatically reinstalls cdk every time you launch a new workspace in gitpod. plus it copies the file .env.example into .env (the file .env.example will be created later)

```sh
 - name: cdk
    before: |
      cd thumbing-serverless-cdk
      cp .env.example .env
      npm i
      npm install aws-cdk -g
      cdk --version
```

To initialise the project type **cdk init app --language typescript**  (instead of typescript, you can choose another language supported by cdk such JavaScript, TypeScript, Python, Java, C#)

To work with the cdkfile, go to the file inside the lib/thumbing-serverless-cdk-stack.ts

To define the s3 buckeet do the following:

import the library for s3 

```sh
import * as s3 from 'aws-cdk-lib/aws-s3';
```

set the variable (Since this project is in typescript which is strongly typed. it means all must have  a specific data type)
```sh
const uploadsBucketName: string = process.env.UPLOADS_BUCKET_NAME as string;
const uploadsBucket = this.createBucket(uploadsBucketName);
```

with the following code, cdk creates the s3 bucket

```sh
 createBucket(bucketName: string): s3.IBucket{
    const bucket = new s3.Bucket(this, 'UploadsBucket', {
      bucketName: bucketName,
      removalPolicy: cdk.RemovalPolicy.DESTROY
    });
    return bucket;
  }
```

To launch the AWS CloudFormation template based on the AWS CDK, type:
```sh
cdk synth
```
**Note** 
- if you run again the code, the folder cdk.out will be updated.
- this is a good way to troubleshoot and see what resources have been created before deploying.

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
If you can deploy your stack and add new resources on top, you will face some issues s with Dynamodb when you start renaming it and there is some data on it. this could delete the entire dynamodb resource.


The next step is to add lambda to our stack.

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
const uploadsBucketName: string = process.env.UPLOADS_BUCKET_NAME as string;
const assetsBucketName: string = process.env.ASSETS_BUCKET_NAME as string;
const functionPath: string = process.env.THUMBING_FUNCTION_PATH as string;
const folderInput: string = process.env.THUMBING_S3_FOLDER_INPUT as string;
const folderOutput: string = process.env.THUMBING_S3_FOLDER_OUTPUT as string;
const webhookUrl: string = process.env.THUMBING_WEBHOOK_URL as string;
const topicName: string = process.env.THUMBING_TOPIC_NAME as string;
console.log('uploadsBucketName',uploadsBucketName)
console.log('assetsBucketName',assetsBucketName)
console.log('folderInput',folderInput)
console.log('folderOutput',folderOutput)
console.log('webhookUrl',webhookUrl)
console.log('topicName',topicName)
console.log('functionPath',functionPath)

const lambda = this.createLambda(functionPath, uploadsBucketName, assetsBucketName, folderInput, folderOutput)

```

and then we create the lambda function

```sh
  createLambda(functionPath: string, uploadsBucketName: string, assetsBucketName:string, folderInput: string, folderOutput: string): lambda.IFunction{
    const lambdaFunction = new lambda.Function(this, 'thumbLambda', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(functionPath),
      environment: {
        DEST_BUCKET_NAME: assetsBucketName,
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
Lambda function needs at least 3 parameters Runtime (language of the code), handler and code (which is the source where is located our code)

create the .env.example inside of our cdk project with the following info
```sh
UPLOADS_BUCKET_NAME="johnbuen-uploaded-avatars"
ASSETS_BUCKET_NAME="assets.yourdomanin.com"
THUMBING_FUNCTION_PATH="/workspace/aws-bootcamp-cruddur-2023/aws/lambdas/process-images"
THUMBING_S3_FOLDER_INPUT="avatars/original"
THUMBING_S3_FOLDER_OUTPUT="avatars/processed"
THUMBING_WEBHOOK_URL="https://api.yourdomain.com/webhooks/avatar"
THUMBING_TOPIC_NAME="crudduer-assets"

```
**Note** 
- It is a good practice to create a folder for the lambda codes for each project so it is to refer to which project belongs the code.

- The UPLOADS_BUCKET_NAME and ASSETS_BUCKET_NAME must be unique as this will refer to the s3 bucket. change the name of the bucket with your domain (for example assets.example.com)

- This file will be copied with the extension ".env" and will be necessery for thumbing-serverless-cdk-stack file.

if you launch the **cdk synth** the result will be something similar to this:

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


Create the folder for the lambda called **process-images** under aws/lambdas

One file called **index.js**

```sh
const process = require('process');
const {getClient, getOriginalImage, processImage, uploadProcessedImage} = require('./s3-image-processing.js')
const path = require('path');

const bucketName = process.env.DEST_BUCKET_NAME
const folderInput = process.env.FOLDER_INPUT
const folderOutput = process.env.FOLDER_OUTPUT
const width = parseInt(process.env.PROCESS_WIDTH)
const height = parseInt(process.env.PROCESS_HEIGHT)

client = getClient();

exports.handler = async (event) => {
  console.log('event',event)

  const srcBucket = event.Records[0].s3.bucket.name;
  const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
  console.log('srcBucket',srcBucket)
  console.log('srcKey',srcKey)

  const dstBucket = bucketName;
  filename = path.parse(srcKey).name
  const dstKey = `${folderOutput}/${filename}.jpg`
  console.log('dstBucket',dstBucket)
  console.log('dstKey',dstKey)

  const originalImage = await getOriginalImage(client,srcBucket,srcKey)
  const processedImage = await processImage(originalImage,width,height)
  await uploadProcessedImage(client,dstBucket,dstKey,processedImage)
};
```

one file called **test.js** which has less code and hardcoded some env vars:
```sh
const {getClient, getOriginalImage, processImage, uploadProcessedImage} = require('./s3-image-processing.js')

async function main(){
  client = getClient()
  const srcBucket = 'cruddur-thumbs'
  const srcKey = 'avatar/original/data.jpg'
  const dstBucket = 'cruddur-thumbs'
  const dstKey = 'avatar/processed/data.png'
  const width = 256
  const height = 256

  const originalImage = await getOriginalImage(client,srcBucket,srcKey)
  console.log(originalImage)
  const processedImage = await processImage(originalImage,width,height)
  await uploadProcessedImage(client,dstBucket,dstKey,processedImage)
}

main()
```

Another file  called **s3-image-processing.js**

```sh
const sharp = require('sharp');
const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");

function getClient(){
  const client = new S3Client();
  return client;
}

async function getOriginalImage(client,srcBucket,srcKey){
  console.log('get==')
  const params = {
    Bucket: srcBucket,
    Key: srcKey
  };
  console.log('params',params)
  const command = new GetObjectCommand(params);
  const response = await client.send(command);

  const chunks = [];
  for await (const chunk of response.Body) {
    chunks.push(chunk);
  }
  const buffer = Buffer.concat(chunks);
  return buffer;
}

async function processImage(image,width,height){
  const processedImage = await sharp(image)
    .resize(width, height)
    .jpeg()
    .toBuffer();
  return processedImage;
}

async function uploadProcessedImage(client,dstBucket,dstKey,image){
  console.log('upload==')
  const params = {
    Bucket: dstBucket,
    Key: dstKey,
    Body: image,
    ContentType: 'image/jpeg'
  };
  console.log('params',params)
  const command = new PutObjectCommand(params);
  const response = await client.send(command);
  console.log('repsonse',response);
  return response;
}

module.exports = {
  getClient: getClient,
  getOriginalImage: getOriginalImage,
  processImage: processImage,
  uploadProcessedImage: uploadProcessedImage
}
```

create the file called **example.json**

This file is just for reference.
```sh
{
    "Records": [
        {
            "eventVersion": "2.1",
            "eventSource": "aws:s3",
            "awsRegion": "eu-west-2",
            "eventTime": "2023-04-04T12:34:56.000Z",
            "eventName": "ObjectCreated:Put",
            "userIdentity": {
                "principalId": "EXAMPLE"
            },
            "requestParameters": {
                "sourceIPAddress": "127.0.0.1"
            },
            "responseElements": {
                "x-amz-request-id": "EXAMPLE123456789",
                "x-amz-id-2": "EXAMPLE123/abcdefghijklmno/123456789"
            },
            "s3": {
                "s3SchemaVersion": "1.0",
                "configurationId": "EXAMPLEConfig",
                "bucket": {
                    "name": "assets.johnbuen.co.uk",
                    "ownerIdentity": {
                        "principalId": "EXAMPLE"
                    },
                    "arn": "arn:aws:s3:::assets.johnbuen.co.uk"
                },
                "object": {
                    "key": "avatars/original/data.jpg",
                    "size": 1024,
                    "eTag": "EXAMPLEETAG",
                    "sequencer": "EXAMPLESEQUENCER"
                }
            }
        }
    ]
  }
```

**Note**
- On the "awsRegion", insert your region
- On "name" under bucket and arn, replace with your bucket name


from the terminal, move to aws\lambdas\process-image\ and launch the following command
```
npm init -y
```
**Note** This create a new init file 

launch these command to install the libraries

```
npm i sharp
npm i @aws-sdk/client-s3

```
**Note** Make sure to check on the internet the library before installing it as there are some packages with similar names

To deploy the CDK project launch the following code. then check it on cloudformation

```sh
cdk deploy
```
**Note**
- Before deploying, CDK launch a synth to check if the code is correct.

- If you rename a bucket and deploy the entire stack, this wont affect the changes. you need to destroy the entire stack and relaunch using the following command:
```
cdk destroy
```

Launch the following command to install Sharp form the folder of CDK
```sh
npm install
rm -rf node_modules/sharp
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux --libc=glibc sharp
```

with the same code, create a bash script under .bin/avatar called build
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
SERVERLESS_PATH=$(dirname $ABS_PATH)
BIN_PATH=$(dirname $SERVERLESS_PATH)
PROJECT_PATH=$(dirname $BIN_PATH)
SERVERLESS_PROJECT_PATH="$PROJECT_PATH/thumbing-serverless-cdk"

cd $SERVERLESS_PROJECT_PATH
npm install
rm -rf node_modules/sharp
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux --libc=glibc sharp
```

under the same folder create bash script called **clear**
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
SERVERLESS_PATH=$(dirname $ABS_PATH)
DATA_FILE_PATH="$SERVERLESS_PATH/files/data.jpg"

aws s3 cp "$DATA_FILE_PATH" "s3://johnbuen-uploaded-avatars/data.jpg"

```



under the same folder create bash script called **upload**
```sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
SERVERLESS_PATH=$(dirname $ABS_PATH)
DATA_FILE_PATH="$SERVERLESS_PATH/files/data.jpg"

aws s3 cp "$DATA_FILE_PATH" "s3://assets.$DOMAIN_NAME/avatars/original/data.jpg"
```

and also a script for the list called **ls**
```sh
#! /usr/bin/bash

aws s3 ls s3://$THUMBING_BUCKET_NAME
```

Create the env var to reference your domain name locally and on gitpod (these 2 line will be done just one time)
```sh
export DOMAIN_NAME="yourdomain.com"
gp env DOMAIN_NAME="yourdomain.com"
```
**Note**: if you are using codespace, make sure to add this env var as well there.

and a folder called **files** where you load the image that will be load to s3.


The next step is to hook up the lambda with s3 Event Notification

It is some additional code to our **thumbing-serverless-cdk-stack.ts**

from the section of  variable add the following command
```sh
this.createS3NotifyToLambda(folderInput,lambda,uploadsBucket)
this.createS3NotifyToSns(folderOutput,snsTopic,assetsBucket)
```

Add also this portion of code to sets up an event notification in an Amazon S3 bucket to trigger a specific AWS Lambda function when an object is created with a PUT operation and a key that matches a specific prefix.

```sh

createS3NotifyToLambda(prefix: string, lambda: lambda.IFunction, bucket: s3.IBucket): void {
  const destination = new s3n.LambdaDestination(lambda);
  bucket.addEventNotification(
    s3.EventType.OBJECT_CREATED_PUT,
    destination//,
    //{prefix: prefix}
  )
}
```

Also it needs the library for s3 notification.

```sh
import * as s3n from 'aws-cdk-lib/aws-s3-notifications';
```

We need to import an existing bucket

```sh
  importBucket(bucketName: string): s3.IBucket{
    const bucket = s3.Bucket.fromBucketName(this,"AssetsBucket", bucketName);
    return bucket;
  }
```


and add the following under the previous one
```sh
const assetsBucket = this.importBucket(assetsBucketName);
```

We will need to create an s3 bucket called **assets.yourdomain.com** manually just for this time.

To add the permission to write to the s3 buckets, add the following code to the **thumbing-serverless-cdk-stack**

```
const s3UploadsReadWritePolicy = this.createPolicyBucketAccess(uploadsBucket.bucketArn)
const s3AssetsReadWritePolicy = this.createPolicyBucketAccess(assetsBucket.bucketArn)


```

add the new function

```sh
createPolicyBucketAccess(bucketArn: string){
    const s3ReadWritePolicy = new iam.PolicyStatement({
      actions: [
        's3:GetObject',
        's3:PutObject',
      ],
      resources: [
        `${bucketArn}/*`,
      ]
    });
    return s3ReadWritePolicy;
  }
```

import the library for iam

```sh
import * as iam from 'aws-cdk-lib/aws-iam';
```

and with these lines of code, lambda will have the policy created under the const **s3ReadWritePolicy**
```sh
lambda.addToRolePolicy(s3UploadsReadWritePolicy);
lambda.addToRolePolicy(s3AssetsReadWritePolicy);
```

The last part of the implementation  notification

from **thumbing-serverless-cdk-stack** add the following 

import the libraries for sns and sns subscription

```sh
import * as sns from 'aws-cdk-lib/aws-sns';
import * as subscriptions from 'aws-cdk-lib/aws-sns-subscriptions';
```

and add the creation of  SNStopic, SNS subscritption, SNS policy and attach to the lambda
```sh
const snsTopic = this.createSnsTopic(topicName)
this.createSnsSubscription(snsTopic,webhookUrl)
//const snsPublishPolicy = this.createPolicySnSPublish(snsTopic.topicArn)
//lambda.addToRolePolicy(snsPublishPolicy);
```

and the add the function to create the sns subscription

```sh
createSnsSubscription(snsTopic: sns.ITopic, webhookUrl: string): sns.Subscription {
  const snsSubscription = snsTopic.addSubscription(
    new subscriptions.UrlSubscription(webhookUrl)
  )
  return snsSubscription;
}
```

add the function to create the snstopic
```sh
createSnsTopic(topicName: string): sns.ITopic{
  const logicalName = "ThumbingTopic";
  const snsTopic = new sns.Topic(this, logicalName, {
    topicName: topicName
  });
  return snsTopic;
}
```

add the function to create the event notification
```sh
createS3NotifyToSns(prefix: string, snsTopic: sns.ITopic, bucket: s3.IBucket): void {
  const destination = new s3n.SnsDestination(snsTopic)
  bucket.addEventNotification(
    s3.EventType.OBJECT_CREATED_PUT, 
    destination,
    {prefix: prefix}
  );
}
```

add the function to create the policy to sns publish

```sh
  /*
  createPolicySnSPublish(topicArn: string){
    const snsPublishPolicy = new iam.PolicyStatement({
      actions: [
        'sns:Publish',
      ],
      resources: [
        topicArn
      ]
    });
    return snsPublishPolicy;
  }
```

# Cloudfront Network Distribution

Next is to create a CDN. We will distribute our image assets using this service. 

[Guide CDN step by step](https://scribehow.com/shared/Create_Cloudfront_distribution__7zZ6diCvTz2YN-h753zqBw)

# Implementation User Profile Page

Create a script called **bootstrap** inside the **bin** directory. it creates local psql and dynamodb.

```sh
#! /usr/bin/bash
set -e
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="bootstrap"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

ABS_PATH=$(readlink -f "$0")
bin_dir=$(dirname $ABS_PATH)

echo "Creation local database"
source "$bin_dir/db/setup"
echo "Creation local dynamodb"
python3 "$bin_dir/ddb/schema-load"
echo "Seeding mock data"
python3 "$bin_dir/ddb/seed"

```

from backend-flask/db/sql/users create a file called **show.sql** with the following code
```sh
SELECT
 (SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
    SELECT  
      users.uuid,
      users.handle,
      users.display_name
      (SELECT
        count(true)
       FROM public.activities
       WHERE
        activities.users_uuid=users.uuid) as cruds_count
  ) object_row) as profile,
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
    SELECT
      activities.uuid,
      users.display_name,
      users.handle,
      activities.message,
      activities.created_at,
      activities.expires_at
    FROM public.activities
    WHERE
      activities.user_uuid = users.uuid
    ORDER by activities.created_at DESC
    LIMIT 40
  ) array_row) as activities
FROM public.users
WHERE
  users.handle = %(handle)s

```

from user_activities.py, change the following code

```sh
  now = datetime.now(timezone.utc).astimezone()
      
      if user_handle == None or len(user_handle) < 1:
        model['errors'] = ['blank_user_handle']
      else:
        now = datetime.now()
        results = [{
          'uuid': '248959df-3079-4947-b847-9e0892d1bab4',
          'handle':  'Andrew Brown',
          'message': 'Cloud is fun!',
          'created_at': (now - timedelta(days=1)).isoformat(),
          'expires_at': (now + timedelta(days=31)).isoformat()
        }]
        model['data'] = results
```

with this
```sh
      if user_handle == None or len(user_handle) < 1:
        model['errors'] = ['blank_user_handle']
      else:
        sql = db.template('users','show')
        results = db.query_object_json(sql,{'handle': user_handle})
        return results
```



comment out the following code
```sh
from datetime import datetime, timedelta, timezone
```

from **user_activities.py**,

add the following library db
```sh
from lib.db import db
```

from the **userfeedpage.js**


Amend the following code:
```sh
 const loadData = async () => {
    try {
      const backend_url = `${process.env.REACT_APP_BACKEND_URL}/api/activities/@${params.handle}`
      await getAccessToken()
      const access_token = localStorage.getItem("access_token") 
      const res = await fetch(backend_url, {
        headers: {
          Authorization: `Bearer ${access_token}`
        },
        method: "GET"
      });
      let resJson = await res.json();
      if (res.status === 200) {
        setProfile(resJson.profile)
        setActivities(resJson.activities)
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  };
```

```

add the following line
```sh
 const [profile, setProfile] = React.useState([]);
```

refactor this part of the code

```sh
return (
    <article>
      <DesktopNavigation user={user} active={'profile'} setPopped={setPopped} />
      <div className='content'>
        <ActivityForm popped={popped} setActivities={setActivities} />
        <div className='activity_feed'>
        <ProfileHeading setPopped={setPoppedProfile} profile={profile} />
          <ActivityFeed activities={activities} />
        </div>
      </div>
      <DesktopSidebar user={user} />
    </article>
  );
}
```


from the **UserFeedPage.js**

changes the following code
```sh
import Cookies from 'js-cookie'
```

with the checkauth library and ad the following
```sh
import {checkAuth, getAccessTokn} from '../lib/CheckAuth';
import ProfileHeading from '../components/ProfileHeading'
add this following code
```sh
const [poppedProfile, setPoppedProfile] = React.useState([]);

```

amend the following code

```sh
checkAuth(setUser);
```

removed the following code
```sh
  const title = `@${params.handle}`;
```

create a new component called **EditProfileButton.js**  and **EditProfileButton.css** under frontend-react-js/src/components 
this allows the users to edit their profile
from the file EditProfileButton.js add this block of code
```sh
import './EditProfileButton.css';
import EditProfileButton from '../components/EditProfileButton';

export default function EditProfileButton(props) {
  const pop_profile_form = (event) => {
    event.preventdefault();
    props.setPopped(true);
    return false;
  }

  return (
    <button onClick={pop_profile_form} className='profile-edit-button' href="#">Edit Profile</button>
  );
}
```
from the **EditProfileButton.css** paste the following code
```sh
.profile-edit-button {
  border: solid 1px rgba (255,255,255,0.5);
  padding: 12px 20px;
  font-size: 18px;
  background: none;
  border-radius: 999px;
  color: rgba(255,255,255,0.8);
  cursor: pointer;
}

.profile-edit-button:hover {
  background:  rgba(255,255,255,0.3);
}
```

 from userfeedpage.js  (to be checked) 
```sh
 return (
    <article>
      <DesktopNavigation user={user} active={'profile'} setPopped={setPopped} />
      <div className='content'>
        <ActivityForm popped={popped} setActivities={setActivities} />
        <div className='activity_feed'>
          <ProfileHeading profile={profile} />
          <ActivityFeed  activities={activities} />
        </div>
      </div>
      <DesktopSidebar user={user} />
    </article>
  );
}
```

remove the following code as not needed
```sh
  const checkAuth = async () => {
    console.log('checkAuth')
    // [TODO] Authenication
    if (Cookies.get('user.logged_in')) {
      setUser({
        display_name: Cookies.get('user.name'),
        handle: Cookies.get('user.username')
      })
    }
  };
```


From **ActivityFeed.js** modify the following line of code with this
```sh
export default function ActivityFeed(props) {
  return (

    <div className='activity_feed_collection'>
      {props.activities.map(activity => {
      return  <ActivityItem setReplyActivity={props.setReplyActivity} setPopped={props.setPopped} key={activity.uuid} activity={activity} />
      })}
    </div>
  );
}
```

from the **HomeFeedPage.js**, it needs some refactoring

```sh
return (
    <article>
      <DesktopNavigation user={user} active={'home'} setPopped={setPopped} />
      <div className='content'>
        <ActivityForm
          user_handle={user} 
          popped={popped}
          setPopped={setPopped} 
          setActivities={setActivities} 
        />
        <ReplyForm 
          activity={replyActivity} 
          popped={poppedReply} 
          setPopped={setPoppedReply} 
          setActivities={setActivities} 
          activities={activities} 
        />
        <div className='activity_feed'>
          <div className='activity_feed_heading'>
            <div className='title'>Home</div>
          </div>
        <ActivityFeed 
            setReplyActivity={setReplyActivity} 
            setPopped={setPoppedReply} 
            activities={activities} 
          />
        </div>
      </div>
      <DesktopSidebar user={user} />
    </article>
  );
```

from **NotificationsFeedPage.js**, do the same amends

```sh
return (
    <article>
      <DesktopNavigation user={user} active={'notification'} setPopped={setPopped} />
      <div className='content'>
        <ActivityForm  
          popped={popped}
          setPopped={setPopped} 
          setActivities={setActivities} 
        />
        <ReplyForm 
          activity={replyActivity} 
          popped={poppedReply} 
          setPopped={setPoppedReply} 
          setActivities={setActivities} 
          activities={activities} 
        />
        <div className='activity_feed'>
          <div className='activity_feed_heading'>
            <div className='title'>Notifications</div>
          </div>
          <ActivityFeed 
            title="Notification" 
            setReplyActivity={setReplyActivity} 
            setPopped={setPoppedReply} 
            activities={activities} 
          />
        </div>
      </div>
      <DesktopSidebar user={user} />
    </article>
  );
}
```

create the **ProfileHeading.js** and  copy the following code

```sh
import './ProfileHeading.css';

export default function ProfileHeading(props) {
  const backgroundImage = 'url("https://assets.example.com/banners/banner.jpg")';
  const style = {
    backgroundImage: backgroundImage,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
  };
  return (
  <div className='activity_feed_heading profile_heading'>
    <div className='title'>{props.profile.display_name}</div>
    <div className="cruds_count">{props.profile.cruds_count} Cruds</div>
    <div className="banner" style={styles}>
      <div className="avatar">
        <img src="https://assets.example.com/avatars/data.jpg"></ img>  
      </div>
    </div>
    <div classname="info">
      <div class='id'>
        <div className="display_name">{props.profile.display_name}</div>
        <div className="handle">@{props.profile.handle}</div>
      </div>
      <EditProfileButton setPopped={props.setPopped} />  
    </div>
  </div>
  );
}
```

Create on s3 under assets.example.com a folder called **banners** and load the data

create the **ProfileHeading.css** and copy the following code
```sh
.profile_heading {
  padding-bottom: 0px;
}
.profile_heading .avatar {
  position: absolute;
  bottom: -74px;
  left: 16px;
}

.profile_heading .avatar img {
  width: 150px;
  height: 150px;
  border-radius: 999px;
  border: solid 8px var(--fg);
}

.profile_heading .banner {
  position: relative; 
  height: 200;
}

.profile_heading .info {
  display: flex;
  flex-direction: row;
  align-items: start;
  padding: 16px;
}

.profile_heading .info .id {
  padding-top: 70px;
  flex-grow: 1;
}

.profile_heading .info .id .display_name {
  font-size: 24px;
  font-weight: bold;
  color: rgb(255,255,255);
    
}

.profile_heading .info .id .handle {
  font-size: 16px;
  color: rgb(255,255,255,0.7);

}

.profile_heading .cruds_Count{
  color: rgb(255,255,255,0.7);
}
```

from s3, create a folder called **banners** under assets.example.com

# Implementation of Migration Backend Endpoint and profile form

The first step to do is to create the profile form to be added to our userfeedpage.
Create the **ProfileForm.js** under the following folder **frontend-react-js/src/components/** 

```sh

import './ProfileForm.css';
import React from "react";
import process from 'process';
import {getAccessToken} from 'lib/CheckAuth';

export default function ProfileForm(props) {
  const [bio, setBio] = React.useState(0);
  const [displayName, setDisplayName] = React.useState(0);

  React.useEffect(()=>{
    console.log('useEffects',props)
    setBio(props.profile.bio);
    setDisplayName(props.profile.display_name);
  }, [props.profile])

  const onsubmit = async (event) => {
    event.preventDefault();
    try {
      const backend_url = `${process.env.REACT_APP_BACKEND_URL}/api/profile/update`
      await getAccessToken()
      const access_token = localStorage.getItem("access_token")
      const res = await fetch(backend_url, {
        method: "POST",
        headers: {
          'Authorization': `Bearer ${access_token}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          bio: bio,
          display_name: displayName
        }),
      });
      let data = await res.json();
      if (res.status === 200) {
        setBio(null)
        setDisplayName(null)
        props.setPopped(false)
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  }

  const bio_onchange = (event) => {
    setBio(event.target.value);
  }

  const display_name_onchange = (event) => {
    setDisplayName(event.target.value);
  }

  const close = (event)=> {
    if (event.target.classList.contains("profile_popup")) {
      props.setPopped(false)
    }
  }

  if (props.popped === true) {
    return (
      <div className="popup_form_wrap profile_popup" onClick={close}>
        <form 
          className='profile_form popup_form'
          onSubmit={onsubmit}
        >
          <div className="popup_heading">
            <div className="popup_title">Edit Profile</div>
            <div className='submit'>
              <button type='submit'>Save</button>
            </div>
          </div>
          <div className="popup_content">
            <div className="field display_name">
              <label>Display Name</label>
              <input
                type="text"
                placeholder="Display Name"
                value={displayName}
                onChange={display_name_onchange} 
              />
            </div>
            <div className="field bio">
              <label>Bio</label>
              <textarea
                placeholder="Bio"
                value={bio}
                onChange={bio_onchange} 
              />
            </div>
          </div>
        </form>
      </div>
    );
  }
}
```

Create the **ProfileForm.css** under **frontend-react-js/src/components/** 

```sh
form.profile_form input[type='text'],
form.profile_form textarea {
  font-family: Arial, Helvetica, sans-serif;
  font-size: 16px;
  border-radius: 4px;
  border: none;
  outline: none;
  display: block;
  outline: none;
  resize: none;
  width: 100%;
  padding: 16px;
  border: solid 1px var(--field-border);
  background: var(--field-bg);
  color: #fff;
}

.profile_popup .popup_content {
  padding: 16px;
}

form.profile_form .field.display_name {
  margin-bottom: 24px;
}

form.profile_form label {
  color: rgba(255,255,255,0.8);
  padding-bottom: 4px;
  display: block;
}

form.profile_form textarea {
  height: 140px;
}

form.profile_form input[type='text']:hover,
form.profile_form textarea:focus {
  border: solid 1px var(--field-border-focus)
}

.profile_popup button[type='submit'] {
  font-weight: 800;
  outline: none;
  border: none;
  border-radius: 4px;
  padding: 10px 20px;
  font-size: 16px;
  background: rgba(149,0,255,1);
  color: #fff;
}

```

Add the new component into the **Userfeedpage** with the amended code
```sh
import './UserFeedPage.css';
import React from "react";
import { useParams } from 'react-router-dom';

import DesktopNavigation  from '../components/DesktopNavigation';
import DesktopSidebar     from '../components/DesktopSidebar';
import ActivityFeed from '../components/ActivityFeed';
import ActivityForm from '../components/ActivityForm';
import {checkAuth, getAccessToken} from '../lib/CheckAuth';
import ProfileHeading from '../components/ProfileHeading';
import ProfileForm from '../components/ProfileForm'

export default function UserFeedPage() {
  const [activities, setActivities] = React.useState([]);
  const [profile, setProfile] = React.useState([]);
  const [popped, setPopped] = React.useState([]);
  const [poppedProfile, setPoppedProfile] = React.useState([]);
  const [user, setUser] = React.useState(null);
  const dataFetchedRef = React.useRef(false);

  const params = useParams();

  const loadData = async () => {
    try {
      const backend_url = `${process.env.REACT_APP_BACKEND_URL}/api/activities/@${params.handle}`
      await getAccessToken()
      const access_token = localStorage.getItem("access_token")
      const res = await fetch(backend_url, {
        headers: {
          Authorization: `Bearer ${access_token}`
        },
        method: "GET"
      });
      let resJson = await res.json();
      if (res.status === 200) {
        setProfile(resJson.profile)
        setActivities(resJson.activities)
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  };


  React.useEffect(()=>{
    //prevents double call
    if (dataFetchedRef.current) return;
    dataFetchedRef.current = true;

    loadData();
    checkAuth(setUser);
  }, [])

  return (
    <article>
      <DesktopNavigation user={user} active={'profile'} setPopped={setPopped} />
      <div className='content'>
        <ActivityForm popped={popped} setActivities={setActivities} />
        <ProfileForm 
          profile={profile}
          popped={poppedProfile} 
          setPopped={setPoppedProfile} 
        />
        <div className='activity_feed'>
          <ProfileHeading setPopped={setPoppedProfile} profile={profile} />
          <ActivityFeed activities={activities} />
        </div>
      </div>  
      <DesktopSidebar user={user} />
    </article>
  );
}
```

We need to edit the **replayform.css**
Remove the following code from the file

```sh
.popup_form_wrap {
  position: fixed;
  height: 100%;
  width: 100%;
  top: 0;
  left: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding-top: 48px;
  background: rgba(255,255,255,0.1)
}

.popup_form {
  background: #000;
  box-shadow: 0px 0px 6px rgba(190, 9, 190, 0.6);
  border-radius: 16px;
  width: 600px;
}

```

and create a file called **Popup.css** and add this code
```sh
.popup_form_wrap {
  z-index: 100;
  position: fixed;
  height: 100%;
  width: 100%;
  top: 0;
  left: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding-top: 48px;
  background: rgba(255,255,255,0.1)
}

.popup_form {
  background: #000;
  box-shadow: 0px 0px 6px rgba(190, 9, 190, 0.6);
  border-radius: 16px;
  width: 600px;
}

.popup_form .popup_heading {
  display: flex;
  flex-direction: row;
  border-bottom: solid 1px rgba(255,255,255,0.4);
  padding: 16px;
}

.popup_form .popup_heading .popup_title{
  flex-grow: 1;
  color: rgb(255,255,255);
  font-size: 18px;

}
```

import the **popup.css** in **app.js**
```sh
import './components/Popup.css';
```

Now it needs to create an Endpoint, add the following code to **app.py**
```sh
@app.route("/api/profile/update", methods=['POST','OPTIONS'])
@cross_origin()
def data_update_profile():
  bio          = request.json.get('bio',None)
  display_name = request.json.get('display_name',None)
  access_token = extract_access_token(request.headers)
  try:
    claims = cognito_token.verify(access_token)
    cognito_user_id = claims['sub']
    model = UpdateProfile.run(
      cognito_user_id=cognito_user_id,
      bio=bio,
      display_name=display_name
    )
    if model['errors'] is not None:
      return model['errors'], 422
    else:
      return model['data'], 200
  except TokenVerifyError as e:
    # unauthenicatied request
    app.logger.debug(e)
    return {}, 401
```

and add the import update_profile to the **app.py**
```sh
from services.update_profile import *

```

create the file **update_profile.py** under the folder **backend-flask/services/**
```sh
from lib.db import db

class UpdateProfile:
  def run(cognito_user_id,bio,display_name):
    model = {
      'errors': None,
      'data': None
    }

    if display_name == None or len(display_name) < 1:
      model['errors'] = ['display_name_blank']

    if model['errors']:
      model['data'] = {
        'bio': bio,
        'display_name': display_name
      }
    else:
      handle = UpdateProfile.update_profile(bio,display_name,cognito_user_id)
      data = UpdateProfile.query_users_short(handle)
      model['data'] = data
    return model

  def update_profile(bio,display_name,cognito_user_id):
    if bio == None:    
      bio = ''

    sql = db.template('users','update')
    handle = db.query_commit(sql,{
      'cognito_user_id': cognito_user_id,
      'bio': bio,
      'display_name': display_name
    })
  def query_users_short(handle):
    sql = db.template('users','short')
    data = db.query_object_json(sql,{
      'handle': handle
    })
    return data
```

create a file called **update.sql** inside the folder **backend-flask/db/sql/users**
the query will do an update inside the table users by setting the bio and the display name for the user
```sh
UPDATE public.users 
SET 
  bio = %(bio)s,
  display_name= %(display_name)s
WHERE 
  users.cognito_user_id = %(cognito_user_id)s
RETURNING handle;
```

Since there is no bio field in the DB, You need to create a migration script.
One solution you can use is the SQL alchemy but it will create nested dependecies.

create a file called **migration** under **.bin/generate/**
```sh
#!/usr/bin/env python3
import time
import os
import sys

if len(sys.argv) == 2:
  name = sys.argv[1].lower()
else:
  print("pass a filename: eg. ./bin/generate/migration add_bio_column")
  exit(0)

timestamp = str(time.time()).replace(".","")

filename = f"{timestamp}_{name.replace('_', '')}.py"

klass = name.replace('_', ' ').title().replace(' ','')

file_content = f"""
from lib.db import db

class {klass}Migration:
  def migrate_sql():
    data = \"\"\"
    \"\"\"
    return data
  def rollback_sql():
    data = \"\"\"
    \"\"\"
    return data

  def migrate():
    db.query_commit({klass}Migration.migrate_sql(),{{
    }})
  def rollback():
    db.query_commit({klass}Migration.rollback_sql(),{{
    }})

migration = AddBioColumnMigration
"""
#remove leading and trailing new line
file_content = file_content.lstrip('\n').rstrip('\n')

current_path = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.abspath(os.path.join(current_path, '..', '..','backend-flask','db','migrations',filename))
print(file_path)

with open(file_path, 'w') as f:
  f.write(file_content)
  ```

Note: we can enforce that the name assigned is lowercase by changing the line with this
```sh
name = sys.argv[1].lower()
```

from the **backend-flask/db/** create a folder called **migration**

Once it is done, do the chmod u+x to the folder **.bin/generate/migration** and launch
Inside the folder **backend-flask/db/migration**, the script will generate a file with this  naming **16811528612904313_add_bio_column.py** 

**Note** the name of the file is generated with the timestamp+add_bio_column.py
the codes below highlighted are the ones from the generated file. add the 2 lines in bold need to be added between each block

```sh
from lib.db import db

class AddBioColumnMigration:
  def migrate_sql():
    data = """
```

**ALTER TABLE public.users ADD COLUMN bio text;**

```sh
    """
    return data
  def rollback_sql():
    data = """
```
**ALTER TABLE public.users DROP COLUMN bio;**
```sh
    """
    return data

  def migrate():
    db.query_commit(AddBioColumnMigration.migrate_sql(),{
    })

  def rollback():
    db.query_commit(AddBioColumnMigration.rollback_sql(),{
    })

migration = AddBioColumnMigration
```

Now you need to create another 2 scripts **bin/db/** 
one called **migrate** with the following code
```sh
#!/usr/bin/env python3

import os
import sys
import glob
import re
import time
import importlib

current_path = os.path.dirname(os.path.abspath(__file__))
parent_path = os.path.abspath(os.path.join(current_path, '..', '..','backend-flask'))
sys.path.append(parent_path)
from lib.db import db

def get_last_successful_run():
  sql = """
    SELECT last_successful_run
    FROM public.schema_information
    LIMIT 1
  """
  return int(db.query_value(sql,{},verbose=False))

def set_last_successful_run(value):
  sql = """
  UPDATE schema_information
  SET last_successful_run = %(last_successful_run)s
  WHERE id = 1
  """
  db.query_commit(sql,{'last_successful_run': value})
  return value

last_successful_run = get_last_successful_run()

migrations_path = os.path.abspath(os.path.join(current_path, '..', '..','backend-flask','db','migrations'))
sys.path.append(migrations_path)
migration_files = glob.glob(f"{migrations_path}/*")


last_migration_file = None
for migration_file in migration_files:
  if last_migration_file == None:
    filename = os.path.basename(migration_file)
    module_name = os.path.splitext(filename)[0]
    match = re.match(r'^\d+', filename)
    if match:
      file_time = int(match.group())
      print("====")
      print(last_successful_run, file_time)
      print(last_successful_run > file_time)
      if last_successful_run > file_time:
        last_migration_file = module_name
        mod = importlib.import_module(module_name)
        print('===== rolling back: ',module_name)
        mod.migration.rollback()
        set_last_successful_run(file_time)

print(last_migration_file)

```
Make the file executable by launching chmod u+x for the  **bin/db/migrate** 

one called **rollback** with the following code
```sh
#!/usr/bin/env python3

import os
import sys
import glob
import re
import time
import importlib

current_path = os.path.dirname(os.path.abspath(__file__))
parent_path = os.path.abspath(os.path.join(current_path, '..', '..','backend-flask'))
sys.path.append(parent_path)
from lib.db import db

def get_last_successful_run():
  sql = """
    SELECT last_successful_run
    FROM public.schema_information
    LIMIT 1
  """
  return int(db.query_value(sql,{},verbose=False))

def set_last_successful_run(value):
  sql = """
  UPDATE schema_information
  SET last_successful_run = %(last_successful_run)s
  WHERE id = 1
  """
  db.query_commit(sql,{'last_successful_run': value})
  return value

last_successful_run = get_last_successful_run()

migrations_path = os.path.abspath(os.path.join(current_path, '..', '..','backend-flask','db','migrations'))
sys.path.append(migrations_path)
migration_files = glob.glob(f"{migrations_path}/*")


last_migration_file = None
for migration_file in migration_files:
  if last_migration_file == None:
    filename = os.path.basename(migration_file)
    module_name = os.path.splitext(filename)[0]
    match = re.match(r'^\d+', filename)
    if match:
      file_time = int(match.group())
      print("====")
      print(last_successful_run, file_time)
      print(last_successful_run > file_time)
      if last_successful_run > file_time:
        last_migration_file = module_name
        mod = importlib.import_module(module_name)
        print('===== rolling back: ',module_name)
        mod.migration.rollback()
        set_last_successful_run(file_time)

print(last_migration_file)
```

Make the file executable by launching chmod u+x for the **bin/db/rollback** 

from the **schema.sql** we need to add the new table that creates the schema_information that stores the last successful run and the last migration file. We need to enter to the psql using the script **./bin/db/connect**

```sh
CREATE TABLE IF NOT EXISTS public.schema_information (
  id integer UNIQUE,
  last_successful_run text
);
```
and launch the following query
```sh
INSERT INTO public.schema_information (id,last_successful_run)
VALUES (1,'0')
ON CONFLICT (id) DO NOTHING;
```

from the **db.py**, change the following lines
```sh
def query_commit(self,sql,params={}):
self.print_sql('commit with returning',sql,params)
```
```sh
def query_array_json(self,sql,params={}):
self.print_sql('array',sql,params)
```
```sh
def query_object_json(self,sql,params={}):
self.print_sql('json',sql,params)
self.print_params(params)
```
```sh
def query_value(self,sql,params={}):
self.print_sql('value',sql,params)
```

with the following
```sh
def query_commit(self,sql,params={},verbose=True):
  if verbose:
  self.print_sql('commit with returning',sql,params)
```
```sh
def query_array_json(self,sql,params={},verbose=True):
  if verbose:
    self.print_sql('array',sql,params)
```
```sh
def query_object_json(self,sql,params={},verbose=True):
  if verbose:
    self.print_sql('json',sql,params)
    self.print_params(params)
```
```sh
def query_value(self,sql,params={},verbose=True):
  if verbose:
    self.print_sql('value',sql,params)
```

Note: to test the Migrate script and Roll script, you need to update manupulate the table schema information and the user.

this query update the value of last successful run to 0
```sh
 update schema_information set last_successful_run = 0;
 ```

this query remove the column bio from the table users
 ```sh
ALTER TABLE public.users DROP COLUMN bio;
```

use also the following command to see the bahaviour of the column
```sh
\d users
```

Change the **ProfileHeading.js**
Need to set the new field visible on our page
```sh
import './ProfileHeading.css';
import EditProfileButton from '../components/EditProfileButton';


export default function ProfileHeading(props) {
    const backgroundImage = 'url("https://assets.johnbuen.co.uk/banners/banner.jpg")';
    const styles = {
        backgroundImage: backgroundImage,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
    };
    return (
    <div className='activity_feed_heading profile_heading'>
        <div className='title'>{props.profile.display_name}</div>
        <div className="cruds_count">{props.profile.cruds_count} Cruds</div>
        <div className="banner" style={styles} >
            <div className="avatar">
                <img src="https://assets.johnbuen.co.uk/avatars/data.jpg"></img>
            </div>
        </div>
        <div className="info">
            <div className='id'>
                <div className="display_name">{props.profile.display_name}</div>
                <div className="handle">@{props.profile.handle}</div>
            </div>
            <EditProfileButton setPopped={props.setPopped} />
        </div>
        <div className="bio">{props.profile.bio}</div>
    </div>
    );
}
```

from **profileheading.css** add the following code
```sh
.profile_heading .bio {
  padding: 16px;
  color: rgba (255,255,255,0.7);
}
```

from **show.sql**, change the entire code so the new field will show on the profile page.
```sh
SELECT
    (SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
        SELECT
            users.uuid,
            users.handle,
            users.display_name,
            users.bio
            (SELECT count(true)
            FROM public.activities
            WHERE
                activities.user_uuid = users.uuid            
            ) as cruds_count
    ) object_row) as profile,
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
        SELECT
            activities.uuid,
            users.display_name,
            users.handle,
            activities.message,
            activities.created_at,
            activities.expires_at
        FROM public.activities
        WHERE
            activities.user_uuid = users.uuid
        ORDER BY activities.created_at DESC
        LIMIT 40
    ) array_row) as activities
FROM public.users
WHERE
    users.handle = %(handle)s
```

# Implementation Avatar Uploading

In this section, we will implement a presigned url to upload an object to S3 using api gateway.
This will create a unique url to upload our file to s3.

Requirements:
- Install [**Thunder Client**](https://www.thunderclient.com/) on your VScode. This tool will be necessary to test the api that we will be generating. (Remember to add to the gitpod.yml and he devcontainer.json so it is available on gitpod and codespaces)

Follow the link of how to create the Lambda function using Ruby
[Link](https://scribehow.com/shared/How_to_Create_a_Lambda_Function_for_Avatar_Uploads__R-6ZtsmgSE6sXqhdItou_Q)

Note:
- Make sure to rename the lambda function from **lambda_handler.rb** to **function.rb**
- From the Runtime settings on your Lambda, rename the default handler called **lambda_function.lambda_handler** to **function.handler**
- Use the code from **function.rb** for the lambda that has been created before.

Create a new file called **function.rb** under the folder **aws/lambdas/cruddur-upload-avatar**
This contains the code for the Lambda that we created previously

Before you need to create the library.
from terminal, go to **aws/lambdas/cruddur-upload-avatar** and run the following code to generate the gem file
```sh
bundle init
```

**Note**: Gem file is a file that manages libraries

From the gem file created before, add the following line inside the file that has been generated:
```sh
gem "aws-sdk-s3"
gem "ox"
get "jwt"
```
Run the following code from the terminal.
This command install all the requiremenets 
```sh
bundle install
```

Note: if you restart the workspace, you have to redo the installation of the requirement

Add the following file code to the **function.rb**:
```ruby

      
#use for debugging
require 'aws-sdk-s3'
require 'json'
require 'aws-sdk-ssm'
require 'jwt'

def handler(event:, context:)
  # Create an AWS SSM client
  ssm_client = Aws::SSM::Client.new
  # Retrieve the value of an environment variable from SSM Parameter Store
  response = ssm_client.get_parameter({
    name: '/cruddur/CruddurAvatarUpload/LAMBDA_FRONTEND',
    with_decryption: true
  })
  # Access the environment variable value
  frontend_url = response.parameter.value
  puts frontend_url

  puts event
  # Return CORS headers for preflight check
  if event['routeKey'] == "OPTIONS /{prefix+}"
    puts({ step: 'preflight', message: 'preflight CORS check' }.to_json)
    {
      headers: {
        "Access-Control-Allow-Headers": "*, Authorization",
        "Access-Control-Allow-Origin": frontend_url,
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
      },
      statusCode: 200,
    }
  else
    token = event['headers']['authorization'].split(' ')[1]
    puts({ step: 'presigned url', access_token: token }.to_json)
    
    body_hash = JSON.parse(event["body"])
    extension = body_hash["extension"]

    decoded_token = JWT.decode token, nil, false
    puts decoded_token
    cognito_user_uuid = decoded_token[0]['sub']
    s3 = Aws::S3::Resource.new
    bucket_name = ENV["UPLOADS_BUCKET_NAME"]
    object_key = "#{cognito_user_uuid}.#{extension}"

    puts({object_key: object_key}.to_json)

    obj = s3.bucket(bucket_name).object(object_key)
    url = obj.presigned_url(:put, expires_in: 300)
    url # this is the data that will be returned
    body = { url: url }.to_json
    {
      headers: {
        "Access-Control-Allow-Headers": "*, Authorization",
        "Access-Control-Allow-Origin": frontend_url,
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
      },
      statusCode: 200,
      body: body
    }
  end
end
#puts handler(
#  event: {},
#  context: {}
#)
```

**Note:** ~~On "Access-Control-Allow-Origin", make sure to insert your `FRONTEND_URL` origin from gitpod which is the url you login to the app and not the url of your gitpod development. Make sure to include the protocol.~~
Later you will use your production origin (i.e `https://example/com`)

to execute the `function.rb` locally launch the following command:
```sh
bundle exec ruby function.rb
```

Make sure to save this variable called **UPLOADS_BUCKET_NAME** inside gitpod/codespace.
You can retrive this file from the **thumbing-serverless-cdk/.env.example**.
Make sure to set it into your dev environment just this time by launching the following command:

```sh
EXPORT UPLOADS_BUCKET_NAME="johnbuen-uploaded-avatars"
```
```sh
gp env UPLOADS_BUCKET_NAME="johnbuen-uploaded-avatars"
```
>Note: change the name of the bucket with yours.
> - Change the name of the bucket with yours.
> - The second line will save the env var into gitpod so it is available for the future

Make sure to create and attach this policy so that retrieve the ssm
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-2:ADDYOURACCOUNTNUMBERHERE:parameter/cruddur/CruddurAvatarUpload/LAMBDA_FRONTEND"
        }
    ]
}

```

Create the script called `parameters` under `./bin/ssm/parameters`
```sh
#! /usr/bin/bash

export URL="https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
aws ssm put-parameter --type "SecureString" --name "/cruddur/CruddurAvatarUpload/LAMBDA_FRONTEND" --value $URL --overwrite
```

Make sure to create the the SSM parameter as well
![image](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/ssm.jpg)

> Note: from the value make sure to paste the url of the FRONTEND_URL. This will be updated using the script when you launch the CDE environment if you have put inside the bootstrap/setup script.

To test if the upload works, use **thunder client**.
As a method use as a put and insert the url generated by the 
**function.rb**. load any kind image by clicking the body

[How to test in Thunder CLient](https://scribehow.com/shared/How_to_test_S3_pre-signed_url_in_ThunderClient_on_Gitpod__qd8QoYDiR0iQWSum5bsSJg)

create a new script under `/bin/lambda-layers` called `ruby-jwt` with the following code:
```bash
#! /usr/bin/bash

gem i jwt -Ni /tmp/lambda-layers/ruby-jwt/ruby/gems/2.7.0
cd  /tmp/lambda-layers/ruby-jwt
zip -r lambda-layers . -x ".*" -x "*/.*"
zipinfo -t lambda-layers

aws lambda publish-layer-version \
  --layer-name jwt \
  --description "Lambda Layer for JWT" \
  --license-info "MIT" \
  --zip-file fileb://lambda-layers.zip \
  --compatible-runtimes ruby2.7

```
This code will generate a file called lambda-layer that contains the jwt and will be published to the lambda layer

Go to the  `CruddurAvatarUpload` lambda, under the section layers click `Add a layer` and follow the following screenshot
![lambda layer](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/jwt.jpg)

Since our Lambda works with another service, it needs to give some additional permission

Create a json file called s3-upload-avatar-presigned-url-policy.json under the folder **aws/policies** and attach the following code

```sh
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::johnbuen-uploaded-avatars/*"
      }
  ]
}
```

>Note: from the section resource of the json statement, change the value of the bucket with yours.

Follow the link
[How to attach new policy](https://scribehow.com/shared/How_to_Add_a_Presigned_URL_Permission_in_AWS_Lambda__sNwZ4eQPTmSb4jN0ia06Jw)

Make sure to add also the Env Var for the lambda similar to the example below

[image](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/implementation-Avatar-uploading/images/uploadbucketname.png)

>Note: Change the value of the bucket with yours.

The next step is to create the lambda authorizer

Create a new file called **index.js** under the folder **aws/lambdas/lambda-authorizer**

```js
"use strict";
const { CognitoJwtVerifier } = require("aws-jwt-verify");
//const { assertStringEquals } = require("aws-jwt-verify/assert");

const jwtVerifier = CognitoJwtVerifier.create({
  userPoolId: process.env.USER_POOL_ID,
  tokenUse: "access",
  clientId: process.env.CLIENT_ID//,
  //customJwtCheck: ({ payload }) => {
  //  assertStringEquals("e-mail", payload["email"], process.env.USER_EMAIL);
  //},
});

exports.handler = async (event) => {
  console.log("request:", JSON.stringify(event, undefined, 2));

  const token = JSON.stringify(event.headers["authorization"]).split(" ")[1].replace(/['"]+/g, '');
  try {
    const payload = await jwtVerifier.verify(token);
    console.log("Access allowed. JWT payload:", payload);
  } catch (err) {
    console.error("Access forbidden:", err);
    return {
      isAuthorized: false,
    };
  }
  return {
    isAuthorized: true,
  };
};
```

from the folder **lambda-authorizer** install the dependecy

```bash
npm install aws-jwt-verify --save
```

Once installed, create a zip file containing all the files of the **lambda-authorizer** by using the following code. 


```bash
cd /workspace/aws-bootcamp-cruddur-2023/aws/lambdas/lambda-authorizer
zip -r lambda-authorizer.zip .
```


The following link is how to create the lambda function authorizer for API gateway [here](https://scribehow.com/shared/Creating_a_New_Lambda_Function_for_API_Gateway_Authorizer__pVyjG006QZKX77JnCq49dg)

Note make sure to add the environment variables as on the image that is on your cognito user pool
![image](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/implementation-Avatar-uploading/images/envvar.png)


Create the api gateway following guide attaching the lambdas created before [Here](https://scribehow.com/shared/How_to_Configure_API_Gateway_with_Lambda_Authorizer__gYXsfpjWSlO3mwiJATt06Q)

from the **profileform.js** add a new function

```js
import './ProfileForm.css';
import React from "react";
import process from 'process';
import {getAccessToken} from 'lib/CheckAuth';

export default function ProfileForm(props) {
  const [bio, setBio] = React.useState('');
  const [displayName, setDisplayName] = React.useState('');

  React.useEffect(()=>{
    setBio(props.profile.bio || '');
    setDisplayName(props.profile.display_name);
  }, [props.profile])

  const s3uploadkey = async (extension)=> {
    console.log('external',extension)
    try {
      const api_gateway = `${process.env.REACT_APP_API_GATEWAY_ENDPOINT_URL}/avatars/key_upload`
      await getAccessToken()
      const access_token = localStorage.getItem("access_token")
      const json = {
          extension: extension
      }
      const res = await fetch(api_gateway, {
        method: "POST",
        body: JSON.stringify(json),
        headers: {
          'Origin': process.env.REACT_APP_FRONTEND_URL,
          'Authorization': `Bearer ${access_token}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
      }})
      let data = await res.json();
      if (res.status === 200) {
        return data.url
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  }

  const s3upload = async (event) => {
    console.log('event',event)
    const file = event.target.files[0]
    console.log('file',file)
    const filename = file.name
    const size = file.size
    const type = file.type
    const preview_image_url = URL.createObjectURL(file)
    console.log(filename, size, type)
    //const formData = new FormData();
    //formData.append('file', file);
    const fileparts = filename.split('.')
    const extension = fileparts[fileparts.length-1]
    const presignedurl = await s3uploadkey(extension)
    try {
      console.log('s3upload')
      const res = await fetch(presignedurl, {
        method: "PUT",
        body: file,
        headers: {
          'Content-Type': type
        }})
   
      //let data = await res.json();
      if (res.status === 200) {
        //setPresignedurl(data.url)
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  }



  const onsubmit = async (event) => {
    event.preventDefault();
    try {
      const backend_url = `${process.env.REACT_APP_BACKEND_URL}/api/profile/update`
      await getAccessToken()
      const access_token = localStorage.getItem("access_token")
      const res = await fetch(backend_url, {
        method: "POST",
        headers: {
          'Authorization': `Bearer ${access_token}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          bio: bio,
          display_name: displayName
        }),
      });
      let data = await res.json();
      if (res.status === 200) {
        setBio(null)
        setDisplayName(null)
        props.setPopped(false)
      } else {
        console.log(res)
      }
    } catch (err) {
      console.log(err);
    }
  }

  const bio_onchange = (event) => {
    setBio(event.target.value);
  }

  const display_name_onchange = (event) => {
    setDisplayName(event.target.value);
  }

  const close = (event)=> {
    if (event.target.classList.contains("profile_popup")) {
      props.setPopped(false)
    }
  }

  if (props.popped === true) {
    return (
      <div className="popup_form_wrap profile_popup" onClick={close}>
        <form 
          className='profile_form popup_form'
          onSubmit={onsubmit}
        >
          <div className="popup_heading">
            <div className="popup_title">Edit Profile</div>
            <div className='submit'>
              <button type='submit'>Save</button>
            </div>
          </div>
          <div className="popup_content">
          <input type="file" name="avatarupload" onChange={s3upload} />
            <div className="field display_name">
              <label>Display Name</label>
              <input
                type="text"
                placeholder="Display Name"
                value={displayName}
                onChange={display_name_onchange} 
              />
            </div>
            <div className="field bio">
              <label>Bio</label>
              <textarea
                placeholder="Bio"
                value={bio}
                onChange={bio_onchange} 
              />
            </div>
          </div>
        </form>
      </div>
    );
  }
}
```

**Note:**
Since we changed some urls hardcoded to `REACT_APP_FRONTEND_URL` and `REACT_APP_API_GATEWAY_ENDPOINT_URL`, you need to add this to your `frontend-react-js.env.erb` as the following:
```sh
REACT_APP_FRONTEND_URL=https://3000-<%= ENV['GITPOD_WORKSPACE_ID'] %>.<%= ENV['GITPOD_WORKSPACE_CLUSTER_HOST'] %>
REACT_APP_API_GATEWAY_ENDPOINT_URL=<%= ENV['API_GATEWAY_ENDPOINT_URL'] %>
```

From the **ProfileForm.css**, add the following code to make visible the **avatar upload**

```css
.profile_popup .upload {
  color: white;
  background: rgba(149,0,255,1);
}
```
from the bucket called `johnbuen-uploaded-avatars` in the section Cross-origin resource sharing (CORS):

add the following code
```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "PUT"
        ],
        "AllowedOrigins": [
            "https://*.gitpod.io"
        ],
        "ExposeHeaders": [
            "x-amz-server-side-encryption",
            "x-amz-request-id",
            "x-amz-id-2"
        ],
        "MaxAgeSeconds": 3000
    }
]
```


# Rendering Avatar using Cloudfront

Create 2 files called `ProfileAvatar.js` and `ProfileAvatar.css` under the `frontend-react-js/src/components`

paste the code for the `ProfileAvatar.js`
```js
import './ProfileAvatar.css';

export default function ProfileAvatar(props) {
    const backgroundImage = `url("https://assets.johnbuen.co.uk/avatars/${props.id}.jpg"`;

    const styles = {
      backgroundImage: backgroundImage,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    };

  return (
    <div 
      className="profile-avatar"
      style={styles}
    ></div>
  );
}
```

for the `profileInfo.js` paste the new code. this will load the new component

```js
import './ProfileInfo.css';
import {ReactComponent as ElipsesIcon} from './svg/elipses.svg';
import React from "react";
import ProfileAvatar from 'components/ProfileAvatar'


// [TODO] Authenication
import { Auth } from 'aws-amplify';

export default function ProfileInfo(props) {
  const [popped, setPopped] = React.useState(false);

  const click_pop = (event) => {
    setPopped(!popped)
  }

  const signOut = async () => {
    try {
        await Auth.signOut({ global: true });
        window.location.href = "/"
        localStorage.removeItem("access_token")
    } catch (error) {
        console.log('error signing out: ', error);
    }
  }

  const classes = () => {
    let classes = ["profile-info-wrapper"];
    if (popped == true){
      classes.push('popped');
    }
    return classes.join(' ');
  }

  return (
    <div className={classes()}>
      <div className="profile-dialog">
        <button onClick={signOut}>Sign Out</button> 
      </div>
      <div className="profile-info" onClick={click_pop}>
        <ProfileAvatar id={props.user.cognito_user_uuid} />
        <div className="profile-desc">
          <div className="profile-display-name">{props.user.display_name || "My Name" }</div>
          <div className="profile-username">@{props.user.handle || "handle"}</div>
        </div>
        <ElipsesIcon className='icon' />
      </div>
    </div>
  )
}
```

from the `ProfileHeading.js`

paste the following new code
```js
import './ProfileHeading.css';
import EditProfileButton from '../components/EditProfileButton';
import ProfileAvatar from 'components/ProfileAvatar'


export default function ProfileHeading(props) {
    const backgroundImage = 'url("https://assets.johnbuen.co.uk/banners/banner.jpg")';
    const styles = {
        backgroundImage: backgroundImage,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
    };
    return (
    <div className='activity_feed_heading profile_heading'>
        <div className='title'>{props.profile.display_name}</div>
        <div className="cruds_count">{props.profile.cruds_count} Cruds</div>
        <div className="banner" style={styles} >
            <ProfileAvatar id={props.profile.cognito_user_uuid} />
        </div>
        <div className="info">
            <div className='id'>
                <div className="display_name">{props.profile.display_name}</div>
                <div className="handle">@{props.profile.handle}</div>
            </div>
            <EditProfileButton setPopped={props.setPopped} />
        </div>
        <div className="bio">{props.profile.bio}</div>
    </div>
    );
}
```

Amend the `show.sql`

```sql
SELECT
    (SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
        SELECT
            users.uuid,
            user.cognito_user_id as cognito_user_uuid,
            users.handle,
            users.display_name,
            users.bio,
            (SELECT count(true)
            FROM public.activities
            WHERE
                activities.user_uuid = users.uuid            
            ) as cruds_count
    ) object_row) as profile,
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
        SELECT
            activities.uuid,
            users.display_name,
            users.handle,
            activities.message,
            activities.created_at,
            activities.expires_at
        FROM public.activities
        WHERE
            activities.user_uuid = users.uuid
        ORDER BY activities.created_at DESC
        LIMIT 40
    ) array_row) as activities
FROM public.users
WHERE
    users.handle = %(handle)s
```

from the `ProfileHeading.css`, paste the new one

```css
.profile_heading {
    padding-bottom: 0px;
}

.profile_heading .profile-avatar {
    position: absolute;
    bottom: -74px;
    left: 16px;
    width: 150px;
    height: 150px;
    border-radius: 999px;
    border: solid 8px var(--fg);
}

.profile_heading .banner {
    position: relative;
    height: 200px;
}

.profile_heading .info {
    display: flex;
    flex-direction: row;
    align-items: start;
    padding: 16px;

}

.profile_heading .info .id {
    padding-top: 70px;
    flex-grow: 1;
}

.profile_heading .info .id .display_name {
    font-size: 24px;
    font-weight: bold;
    color: rgb(255, 255, 255);
}

.profile_heading .info .id .handle {
    font-size: 16px;
    color: rgb(255, 255, 255, 0.7);
}

.profile_heading .cruds_count {
    font-size: 14px;
    color: rgb(255, 255, 255, 0.3);
}

.profile_heading .bio {
    padding: 16px;
    color: rgb(255, 255, 255);
}
```








## Troubleshooting section

When i have to investigate, i check on my cloudwatch log groups to see if the lambda works.
In specific check the log for the `CruddurAvatarUpload` and `CruddurApiGatewayLambdaAuthorizer`



## Reference:
- [AWS cost](https://aws.amazon.com/free/)

