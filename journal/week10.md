# Week 10 — CloudFormation Part 

This week the team will be talking about Cloudformation.

The following link will show the diagram architecture
[CFN Architecture](https://drive.google.com/file/d/1frViHBbn4g0lxnrz9VyypsriJ06nIb6h/view?usp=sharing)

## Cost
In Cloudformation, you only pay for what you use, with no minimum fees and no required upfront commitment.
If you are using a registry extension with cloudformation, you incur charges per handler operation.,
Handler operations are: `CREATE`, `UPDATE`, `DELETE`, `READ`, or `LIST` actions on a resource type and `CREATE`, `UPDATE`, or `DELETE` actions for Hook type.

## Security

## CFN Live Streaming


create a file called `template.yaml`  under the `aws/cfn` with the following structure

```yaml
AWSTempleteFormatVersion: 2010-09-09
Description: |
    Setup ECS Cluster

Resources:
  ECSCluster: #Logical Name 
    Type: 'AWS::ECS::Cluster'
    Properties:
        ClusterName: MyCluster
        CapacityProviders:
            - FARGATE
#Parameters:
#Mappings:
#Resources:
#Outputs:
#Metadata



```
Note: 
- Some aws services want the extension `.yml`. An example is `buildspec` (codebuild). Other services like cloudformation want the `.yaml`` extension. For some samples, you can reference the  [aws templates](https://aws.amazon.com/cloudformation/resources/templates/)


Create an s3 bucket in the same region using the following command:

```bash
export RANDOM_STRING=$(aws secretsmanager get-random-password --exclude-punctuation --exclude-uppercase --password-length 6 --output text --query RandomPassword)
aws s3 mb s3://cfn-artifacts-$RANDOM_STRING

export CFN_BUCKET="cfn-artifacts-$RANDOM_STRING"

gp env CFN_BUCKET="cfn-artifacts-$RANDOM_STRING"
```
Note: This command creates an S3 Bucket called `cfn-artifacts-xxxxxx`. The xxxxxx will be generated randomly by the secret manager.

To deploy the cloudformation, create a folder called  `cfn` and inside call the script `deploy`
```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root in case you use a local dev
export THEIA_WORKSPACE_ROOT=$(pwd)
echo $THEIA_WORKSPACE_ROOT


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/template.yaml"

cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name "Cruddur" \
  --template-file $CFN_PATH \
  --s3-bucket cfn-artifacts-$RANDOM_STRING \
  --no-execute-changeset \
  --capabilities CAPABILITY_NAMED_IAM
```
Note: 
- the   `--no-execute-changeset` will validate the code but not execute it.
- Once you run the command, the cli will create a script to check the outcome. you can use the code generated or check it on the cloud formation via the console.
- changeset in the console is useful to understand the behaviour of the change and to see if there is a difference in your infrastructure (i.e a critical database run in production. By seeing the changeset you know if the resource will be removed). check also the Update requires voice in the [documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-service.html)
- check the tab `replacement` if it is `true`. this helps to see if one part of the stack will be replaced.

from the aws console, check the stack deploy and see what has been deployed. click on `execute` change set`

Install cfn lint using the following command
```bash
pip install cfn-lint
```

and also add into gitpod.yml/.devcontainer file so it is installed in your cloud environment such as codespaces or gitpod.

```yaml
- name: CFN
    before: |
      pip install cfn-lint
      cargo install cfn-guard
```

Create a `task-definition.guard` under the `aws/cfn`

```guard
aws_ecs_cluster_configuration {
  rules = [
    {
      rule = "task_definition_encryption"
      description = "Ensure task definitions are encrypted"
      level = "error"
      action {
        type = "disallow"
        message = "Task definitions in the Amazon ECS cluster must be encrypted"
      }
      match {
        type = "ecs_task_definition"
        expression = "encrypt == false"
      }
    },
    {
      rule = "network_mode"
      description = "Ensure Fargate tasks use awsvpc network mode"
      level = "error"
      action {
        type = "disallow"
        message = "Fargate tasks in the Amazon ECS cluster must use awsvpc network mode"
      }
      match {
        type = "ecs_task_definition"
        expression = "network_mode != 'awsvpc'"
      }
    },
    {
      rule = "execution_role"
      description = "Ensure Fargate tasks have an execution role"
      level = "error"
      action {
        type = "disallow"
        message = "Fargate tasks in the Amazon ECS cluster must have an execution role"
      }
      match {
        type = "ecs_task_definition"
        expression = "execution_role == null"
      }
    },
  ]
}

```

Note: cfn-guard is an open-source command line interface (CLI) that checks CloudFormation templates for policy compliance using a simple, policy-as-code, declarative language. for more details refer to the following [link](https://github.com/aws-cloudformation/cloudformation-guard)

to install cfn-guard 
```bash
cargo install cfn-guard
```

launch the following command
```bash
cfn-guard rulegen --template /workspace/aws-bootcamp-cruddur-2023/aws/cfn/template.yaml
```

it will give the following result
```
let aws_ecs_cluster_resources = Resources.*[ Type == 'AWS::ECS::Cluster' ]
rule aws_ecs_cluster when %aws_ecs_cluster_resources !empty {
  %aws_ecs_cluster_resources.Properties.CapacityProviders == ["FARGATE"]
  %aws_ecs_cluster_resources.Properties.ClusterName == "MyCluster"
}
```

copy the following code and create a file called `ecs-cluster.guard` under `aws/cfn`

and run the following command
```
cfn-guard validate -r ecs-cluster.guard
```
Note: make sure to be in the directory where is the file




## CFN Network Template

Create a file called `template.yaml` under the path `aws/cfn/networking`
This file will contain the structure of our network layer such as VPC, Internet Gateway, Route tables and 6 Public/Private Subnets, route table, and the outpost.

```yaml
AWSTemplateFormatVersion: 2010-09-09

Parameters:
  VpcCidrBlock:
    Type: String
    Default: 10.0.0.0/16
  SubnetCidrBlocks:
    Description: "Comma-delimited list of CIDR blocks for our private and public subnets"
    Type: CommaDelimitedList
    Default: >
      10.0.0.0/22,
      10.0.4.0/22,
      10.0.8.0/22,
      10.0.12.0/22,
      10.0.16.0/22, 
      10.0.20.0/22
  Az1:
    Type: AWS::EC2::AvailabilityZone::Name
    Default: eu-west-2a
  Az2:
    Type: AWS::EC2::AvailabilityZone::Name
    Default: eu-west-2b
  Az3:
    Type: AWS::EC2::AvailabilityZone::Name
    Default: eu-west-2c
# VPC
Resources:
  VPC:
  #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidrBlock
      EnableDnsHostnames: true
      EnableDnsSupport: true
      InstanceTenancy: default
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}VPC"
  IGW:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-internetgateway.html
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}IGW"
  AttachIGW:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc-gateway-attachment.html
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref IGW
  RouteTable:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-routetable.html
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}RT"
  RouteToIGW:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-route.html
    Type: AWS::EC2::Route
    DependsOn: AttachIGW
    Properties:
      RouteTableId: !Ref RouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref IGW
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
  SubnetPub1:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: !Select [0, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az1
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: true #public subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPub1"
  SubnetPub2:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: !Select [1, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az2
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: true #public subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPub2"
  SubnetPub3:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock:  !Select [2, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az3
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: true #public subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPub3"
  SubnetPri1:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock:  !Select [3, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az1
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: false #private subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPri1"
  SubnetPri2:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock:  !Select [4, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az2
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: false #private subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPri2"
  SubnetPri3:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock:  !Select [5, !Ref SubnetCidrBlocks]
      AvailabilityZone: !Ref Az3
      VpcId: !Ref VPC
      EnableDns64: false
      MapPublicIpOnLaunch: false #privte subnet
      Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}SubnetPri3"
  SubnetPub1RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPub1
      RouteTableId: !Ref RouteTable
  SubnetPub2RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPub2
      RouteTableId: !Ref RouteTable
  SubnetPub3RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPub3
      RouteTableId: !Ref RouteTable
  SubnetPri1RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPri1
      RouteTableId: !Ref RouteTable
  SubnetPri2RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPri2
      RouteTableId: !Ref RouteTable
  SubnetPri3RTAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref SubnetPri3
      RouteTableId: !Ref RouteTable

Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: VpcId
  VpcCidrBlock:
    Value: !GetAtt VPC.CidrBlock
    Export:
      Name: VpcCidrBlock
  SubnetCidrBlocks:
    Value: !Join [",", !Ref SubnetCidrBlocks]
    Export:
      Name: SubnetCidrBlocks
  SubnetIds:
    Value: !Join
      - ","
      - - !Ref SubnetPub1
        - !Ref SubnetPub2
        - !Ref SubnetPub3
        - !Ref SubnetPri1
        - !Ref SubnetPri2
        - !Ref SubnetPri3
    Export:
      Name: SubnetIds
  AvailabilityZones:
    Value: !Join
      - ","
      - - !Ref Az1
        - !Ref Az2
        - !Ref Az3
    Export:
      Name: AvailabilityZones

```

If you want to get the list of your region:

```bash
aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION
```
Note: If you have set `$AWS_DEFAULT_REGION`, this is the region that you have inserted in your env vars either locally or on Gitpod/Codespace

Change the script create before

```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root in case you use a local dev
export THEIA_WORKSPACE_ROOT=$(pwd)
echo $THEIA_WORKSPACE_ROOT


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/networking/template.yaml"

cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name "Cruddur" \
  --template-file $CFN_PATH \
  --s3-bucket cfn-artifacts-$RANDOM_STRING \
  --no-execute-changeset \
  --capabilities CAPABILITY_NAMED_IAM
```


















## Debug

to debug try to check `cloudtrail` to see the error

to validate the yaml/json template, use the following command
```bash
​aws cloudformation validate-template --template-body file:///workspace/aws-bootcamp-cruddur-2023/aws/cfn/template.yaml
```

another tool is to use `cfn lint`

Install cfn lint using the following command
```bash
pip install cfn-lint
```

and the run the following command
```bash
cfn-lint /workspace/aws-bootcamp-cruddur-2023/aws/cfn/template.yaml
```

Use the cloud formation designer if you want to convert your yaml file to json or viceversa.

### Reference

- [AWS Cloudformation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

