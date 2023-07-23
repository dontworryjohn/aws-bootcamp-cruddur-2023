# Week 10 — CloudFormation Part 

This week the team will be talking about Cloudformation.

The following link will show the 
[diagram architecture](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&layers=1&nav=1&title=CFN%20Diagram.drawio#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1frViHBbn4g0lxnrz9VyypsriJ06nIb6h%26export%3Ddownload)

## Cost
In Cloudformation, you only pay for what you use, with no minimum fees and no required upfront commitment.
If you are using a registry extension with cloudformation, you incur charges per handler operation.,
Handler operations are: `CREATE`, `UPDATE`, `DELETE`, `READ`, or `LIST` actions on a resource type and `CREATE`, `UPDATE`, or `DELETE` actions for Hook type.

## Security

Amazon Side - Security Best Practice
- Compliance standard is what your business requires from IaC service and is available in the region you need to operate
- Amazon Organization SCP - restrict action (create, delete, modification) on production template/resource.
- AWS Cloudtrail is enabled & monitored to trigger alerts for malicious activity.
- AWS Audit Manager, IAM Access Analyzer

Application Side - Security Best Practice

- Use the linting to avoid hardcoded secrets and fix eventually indentation
- IAM to control who can access the CFN template
- Security of the cloudformation. Configuration access
- Security in the cloudformation.
- Security of the cloudformation entry point.
- Develop a process for continuously verifying if there is a change that may break the cicd pipeline

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
  --stack-name "CrdNet" \
  --template-file $CFN_PATH \
  --s3-bucket cfn-artifacts-$RANDOM_STRING \
  --no-execute-changeset \
  --tags group=cruddur-cluster \
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
Description: |
  Base networking components for the stack
  - VPC
    - sets DNS hostname for EC2 Instances
    - Only IPV4, IPV6 is disabled
  - InternetGateway
  - RouteTable
    - Route to IGW
    - Route to Local
  - 6 Subnet Explicity Associated to Route Table
    - 3 Public Subnets numbered 1 to 3
    - 3 Private Subnets numbered 1 to 3
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
      Name: !Sub "${AWS::StackName}VpcId"
  VpcCidrBlock:
    Value: !GetAtt VPC.CidrBlock
    Export:
      Name: !Sub "${AWS::StackName}VpcCidrBlock"
  SubnetCidrBlocks:
    Value: !Join [",", !Ref SubnetCidrBlocks]
    Export:
      Name: !Sub "${AWS::StackName}SubnetCidrBlocks"
  PublicSubnetIds:
    Value: !Join
      - ","
      - - !Ref SubnetPub1
        - !Ref SubnetPub2
        - !Ref SubnetPub3
    Export:
      Name: !Sub "${AWS::StackName}PublicSubnetIds"
  PrivateSubnetIds:
    Value: !Join
      - ","
      - - !Ref SubnetPri1
        - !Ref SubnetPri2
        - !Ref SubnetPri3
    Export:
      Name: !Sub "${AWS::StackName}PrivateSubnetIds"
  AvailabilityZones:
    Value: !Join
      - ","
      - - !Ref Az1
        - !Ref Az2
        - !Ref Az3
    Export:
      Name: !Sub "${AWS::StackName}AvailabilityZones"


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


## CFN Cluster Template

First, create a bash script called `cluster-deploy` under `/bin/cfn`
```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/cluster/template.yaml"


cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name "CrdCluster" \
  --template-file $CFN_PATH \
  --s3-bucket "cfn-artifacts-$RANDOM_STRING" \
  --no-execute-changeset \
  --tags group=cruddur-cluster \
  --capabilities CAPABILITY_NAMED_IAM
```

Create a file called `template.yaml` under the path `aws/cfn/cluster`
This file will contain the structure of our containers such as the frontend and the backend container, target groups, application load balancer

```yaml
AWSTemplateFormatVersion: 2010-09-09

Description: |
  Application Load Balancer and Cluster configuration to support fargate containers
  - ECS Fargate Cluster
  - ALB
    - Ipv4 only
    - internet facing
    - Certificate in ACM
  - ALB security group
  - HTTPS Listener
    - send naked domain to frontend target group
    - send api. subdomain to backend target group
  - HTTP Listener
    - Redirect to HTTPS listener
  - Target Groups (Backend and Frontend)

Parameters:
  NetworkingStack:
    Type: String
    Description: This is the base layer of networking components
    Default: CrdNet
  CertificateArn:
    Type: String

  # frontend 
  
  FrontendPort:
    Type: Number
    Default: 3000
  FrontendHealthCheckIntervalSeconds:
    Type: Number
    Default: 20
  FrontendHealthCheckPath:
    Type: String
    Default: "/"
  FrontendHealthCheckPort: 
    Type: String
    Default: 80
  FrontendHealthCheckProtocol:
    Type: String
    Default: HTTP
  FrontendHealthCheckTimeoutSeconds:
    Type: Number
    Default: 5
  FrontendHealthyThresholdCount:
    Type: Number
    Default: 2
  FrontendUnhealthyThresholdCount:
    Type: Number
    Default: 2
  # Backend healthcheck
  BackendPort:
    Type: Number
    Default: 4567
  BackendHealthCheckIntervalSeconds:
    Type: String
    Default: 20
  BackendHealthCheckPath:
    Type: String
    Default: "/api/health-check"
  BackendHealthCheckPort:
    Type: String
    Default: 4567
  BackendHealthCheckProtocol:
    Type: String
    Default: HTTP
  BackendHealthCheckTimeoutSeconds:
    Type: Number
    Default: 5
  BackendHealthyThresholdCount:
    Type: Number
    Default: 2
  BackendUnhealthyThresholdCount:
    Type: Number
    Default: 2

    
Resources:
  FargateCluster: #LogicalName
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub "${AWS::StackName}FargateCluster"
      CapacityProviders:
        - FARGATE
      ClusterSettings:
        - Name: containerInsights
          Value: enabled
      Configuration:
        ExecuteCommandConfiguration:
          #KmsKeyId: !Ref KmsKeyId
          Logging: DEFAULT
      ServiceConnectDefaults:
        Namespace: Crud
  ALB:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-loadbalancer.html
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub "${AWS::StackName}ALB"
      Type: application
      IpAddressType: ipv4
      Scheme: internet-facing
      SecurityGroups:  
        - !GetAtt ALBSecurityGroup.GroupId
      Subnets:
        Fn::Split:
          - ","
          - Fn::ImportValue:
              !Sub "${NetworkingStack}PublicSubnetIds"

      LoadBalancerAttributes:
        - Key: routing.http2.enabled
          Value: true
        - Key: routing.http.preserve_host_header.enabled
          Value: false
        - Key: deletion_protection.enabled
          Value: false
        - Key: load_balancing.cross_zone.enabled
          Value: true
        # for logs purposes
        #- Key: access_logs.s3.enabled
        #  Value: false
        #- Key: access_logs.s3.bucket
        #  Value: bucket-name
        #- Key: access_logs.s3.prefix
        #  Value: ""
  HTTPSListener:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-listener.html
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties: 
      Protocol: HTTPS
      Port: 443
      LoadBalancerArn: !Ref ALB
      Certificates: 
        - CertificateArn: !Ref CertificateArn
      DefaultActions: 
        - Type: forward
          TargetGroupArn: !Ref FrontendTG
  HTTPListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      Protocol: HTTP
      Port: 80
      LoadBalancerArn: !Ref ALB
      DefaultActions: 
        - Type: redirect
          RedirectConfig:
            Protocol: "HTTPS"
            Port: 443
            Host: "#{host}"
            Path: "/#{path}"
            Query: "#{query}"
            StatusCode: "HTTP_301"
  ApiALBListenerRule:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-listenerrule.html
    Type: AWS::ElasticLoadBalancingV2::ListenerRule
    Properties: 
      Conditions: 
        - Field: host-header
          HostHeaderConfig:
            Values: 
              - api.johnbuen.com
      Actions: 
        - Type: forward
          TargetGroupArn: !Ref BackendTG
      ListenerArn: !Ref HTTPSListener
      Priority: 1

  ALBSecurityGroup:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group.html
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupDescription: Allow Ingress traffic from the internet
      GroupName: !Sub "${AWS::StackName}ALBSecurityGroup"
      VpcId: 
        Fn::ImportValue:
            !Sub ${NetworkingStack}VpcId
      SecurityGroupIngress: 
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: '0.0.0.0/0'
          Description: CONNECTION HTTPS
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: '0.0.0.0/0'
          Description: CONNECTION HTTP
  # Need to create this SG before to pass it to the database SG
  ServiceSG:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group.html
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupDescription: SG for the Fargate SG for cruddur
      GroupName: !Sub "${AWS::StackName}ServSG"
      VpcId: 
        Fn::ImportValue:
            !Sub ${NetworkingStack}VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          SourceSecurityGroupId: !GetAtt ALBSecurityGroup.GroupId
          FromPort: !Ref BackendPort
          ToPort: !Ref BackendPort
          Description: Container Backend
  BackendTG:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-targetgroup.html
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      #Name: !Sub "${AWS::StackName}BackendTG"
      Port: !Ref BackendPort
      HealthCheckEnabled: true
      HealthCheckIntervalSeconds: !Ref BackendHealthCheckIntervalSeconds
      HealthCheckPath: !Ref BackendHealthCheckPath
      HealthCheckPort: !Ref BackendHealthCheckPort
      HealthCheckProtocol: !Ref BackendHealthCheckProtocol
      HealthCheckTimeoutSeconds: !Ref BackendHealthCheckTimeoutSeconds
      HealthyThresholdCount: !Ref BackendHealthyThresholdCount
      UnhealthyThresholdCount: !Ref  BackendUnhealthyThresholdCount
      IpAddressType: ipv4
      Matcher: 
        HttpCode: 200
      Protocol: HTTP
      ProtocolVersion: HTTP2
      TargetType: ip
      TargetGroupAttributes: 
        - Key: deregistration_delay.timeout_seconds
          Value: 0
      VpcId: 
        Fn::ImportValue:
            !Sub ${NetworkingStack}VpcId
      Tags:
        - Key: target-group-name
          Value: Backend

  FrontendTG:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      #Name: !Sub "${AWS::StackName}FrontendTG"
      Port: !Ref FrontendPort
      HealthCheckProtocol: !Ref FrontendHealthCheckProtocol
      HealthCheckEnabled: true
      HealthCheckIntervalSeconds: !Ref FrontendHealthCheckIntervalSeconds
      HealthCheckPath: !Ref FrontendHealthCheckPath
      HealthCheckPort: !Ref FrontendHealthCheckPort       
      HealthCheckTimeoutSeconds: !Ref FrontendHealthCheckTimeoutSeconds
      HealthyThresholdCount: !Ref FrontendHealthyThresholdCount
      UnhealthyThresholdCount: !Ref  FrontendUnhealthyThresholdCount
      IpAddressType: ipv4
      Matcher: 
        HttpCode: 200
      Protocol: HTTP
      ProtocolVersion: HTTP2
      TargetType: ip
      TargetGroupAttributes: 
        - Key: deregistration_delay.timeout_seconds
          Value: 0
      VpcId: 
        Fn::ImportValue:
           !Sub ${NetworkingStack}VpcId
      Tags:
        - Key: target-group-name
          Value: Frontend

Outputs:
  ClusterName:
    Value: !Ref FargateCluster
    Export:
      Name: !Sub "${AWS::StackName}ClusterName"
  ALBSecurityGroupId:
    Value: !GetAtt  ALBSecurityGroup.GroupId
    Export:
      Name: !Sub "${AWS::StackName}ALBSecurityGroupId"
  ServiceSecurityGroupId:
    Value: !GetAtt  ServiceSG.GroupId
    Export:
      Name: !Sub "${AWS::StackName}ServiceSecurityGroupId"
  BackendTargetGroup:
    Value: !Ref BackendTG
    Export:
      Name: !Sub "${AWS::StackName}BackendTargetGroup"
  FrontendTargetGroup:
    Value: !Ref FrontendTG
    Export:
      Name: !Sub "${AWS::StackName}FrontendTargetGroup"
```

## CFN-Toml tool

To pass the env var inside a cloud formation template, you need to use `cfn-toml`.
The value(s) inside `config.toml` file can be loaded via CLI and replace the missing env var for your CFN template.

First, launch the code to install inside dev environment.

```sh
gem install cfn-toml
```

If you using a Cloud dev environment such gitpod, make sure to add the following line under the `.gitpod.yml`
```yml
tasks:
  - name: CFN
    before: |
      pip install cfn-lint
      cargo install cfn-guard
      gem install cfn-toml
```

Create the file `config.toml` under the `aws/cfn/cluster`

```t
[deploy]
bucket = 'cfn-artifacts-${RANDOM_STRING}'
region = '${AWS_DEFAULT_REGION}'
stack_name = 'CrdCluster'

[parameters]
CertificateArn = 'arn:aws:acm:eu-west-2:238967891447:certificate/38509d88-605d-4f28-ab4f-76d8b880b99f'
NetworkingStack = 'CrdNet'
```

if you want to check your certification arn, type the following code

```sh
aws acm list-certificates --query 'CertificateSummaryList[0].CertificateArn' --output text
```


modify the `cluster-deploy` script that contains some code for the `cfn-toml` 

```sh

#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/cluster/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/cluster/config.toml"
echo $CONFIG_PATH

cfn-lint $CFN_PATH

BUCKET=$(cfn-toml key deploy.bucket -t $CONFIG_PATH)
REGION=$(cfn-toml key deploy.region -t $CONFIG_PATH)
STACK_NAME=$(cfn-toml key deploy.stack_name -t $CONFIG_PATH)
PARAMETERS=$(cfn-toml params v2 -t $CONFIG_PATH)


aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file $CFN_PATH \
  --s3-bucket $BUCKET \
  --region $REGION \
  --no-execute-changeset \
  --tags group=cruddur-cluster \
  --parameter-overrides $PARAMETERS \
  --capabilities CAPABILITY_NAMED_IAM

```

modify the `networking-deploy` script that contains some code for the `cfn-toml`

```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)

CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/networking/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/networking/config.toml"
echo $CONFIG_PATH

cfn-lint $CFN_PATH

BUCKET=$(cfn-toml key deploy.bucket -t $CONFIG_PATH)
REGION=$(cfn-toml key deploy.region -t $CONFIG_PATH)
STACK_NAME=$(cfn-toml key deploy.stack_name -t $CONFIG_PATH)
#PARAMETERS=$(cfn-toml params v2 -t $CONFIG_PATH)



cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file $CFN_PATH \
  --s3-bucket $BUCKET \
  --region $REGION \
  --no-execute-changeset \
  --tags group=cruddur-network \
  --capabilities CAPABILITY_NAMED_IAM
```
 

Create the file `config.toml` under the `aws/cfn/networking`
```
[deploy]
bucket = 'cfn-artifacts-39r1pe'
region = 'eu-west-2'
stack_name = 'CrdNet'
```

Note: on the `config.toml` the value to pass must be hardcoded.
You can pass here the parameters rather than the  `cfn template`


Create the file config.toml under the aws/cfn/service
```s
[deploy]
bucket = 'cfn-artifacts-39r1pe'
region = 'eu-west-2'
stack_name = 'CrdSrvBackendFlask'
```

## CFN Backend Service Template

In this part, we will be creating the service layer

First, create a file called `template.yaml` under `/aws/cfn/service`

```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: |
  Backend Service
    -Task Definition File
    -Fargate Service
    -Task Role
    -Execution Role

Parameters:
  NetworkingStack:
    Type: String
    Description: This is the base layer of networking components
    Default: CrdNet
  ClusterStack:
    Type: String
    Description: This is the Cluster Layer 
    Default: CrdCluster
  ContainerPort:
    Type: Number
    Default: 4567
  ServiceCpu:
    Type: String
    Default: '256'
  ServiceMemory:
    Type: String
    Default: '512'
  ServiceName:
    Type: String
    Default: backend-flask
  ContainerName:
    Type: String
    Default: backend-flask
  TaskFamily:
    Type: String
    Default: backend-flask
  EcrImage:
    Type: String
    Default: '238967891447.dkr.ecr.eu-west-2.amazonaws.com/backend-flask:latest'

  EnvOtelServiceName:
    Type: String
    Default: backend-flask
  EnvOtelExporterOtlpEndpoint:
    Type: String
    Default: https://api.honeycomb.io
  EnvAwsCognitoUserPoolId:
    Type: String
    Default: eu-west-2_rNUe2sEXo
  EnvAwsCognitoUserPoolClientId:
    Type: String
    Default: 3870k3kbsr6tbkj6bltab924bp
  EnvFrontEnd:
    Type: String
    Default: "*"
  EnvBackEnd:
    Type: String
    Default: "*"
  SecretsAwsAccessKeyId:
    Type: String
    Default: "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/AWS_ACCESS_KEY_ID"
  SecretsAwsSecretAccessKey:
    Type: String
    Default:  "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/AWS_SECRET_ACCESS_KEY"
  SecretsConnectionUrl:
    Type: String
    Default:  "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/CONNECTION_URL"
  SecretsRollbarAccessToken:
    Type: String
    Default:  "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/ROLLBAR_ACCESS_TOKEN"
  SecretsOtelExporterOtlpHeaders:
    Type: String
    Default:  "arn:aws:ssm:eu-west-2:238967891447:parameter/cruddur/backend-flask/OTEL_EXPORTER_OTLP_HEADERS"

Resources:
  #ServiceSG:
  #  Type: AWS::EC2::SecurityGroup
  #  Properties:
  #    GroupName: !Sub "${AWS::StackName}ALBSecurityGroup"
  #    GroupDescription: Security Group from ALB and Targetgroup
  #    VpcId: 
  #      Fn::ImportValue: 
  #        !Sub "${NetworkingStack}VpcId"
  #    SecurityGroupIngress: 
  #      - IpProtocol: tcp
  #        SourceSecurityGroupId:
  #          Fn::ImportValue:
  #            !Sub "${ClusterStack}ALBSecurityGroupId"
  #        FromPort: 4567
  #        ToPort: 4567
  #        Description: ALB HTTP

  FargateService:
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-service.html
    Type: AWS::ECS::Service
    Properties:
      Cluster:
        Fn::ImportValue:
          !Sub "${ClusterStack}ClusterName"
      DeploymentController:
        Type: ECS
      DesiredCount: 1
      EnableECSManagedTags: true
      EnableExecuteCommand: true
      HealthCheckGracePeriodSeconds: 0
      LaunchType: FARGATE
      LoadBalancers:
        - TargetGroupArn:
            Fn::ImportValue:
              !Sub "${ClusterStack}BackendTargetGroup"
          
          ContainerName: backend-flask
          ContainerPort: !Ref ContainerPort
      NetworkConfiguration:
        AwsvpcConfiguration:
          AssignPublicIp: ENABLED
          SecurityGroups:
            - Fn::ImportValue:
                !Sub "${ClusterStack}ServiceSecurityGroupId"
          Subnets:
            Fn::Split:
              - ","
              - Fn::ImportValue:
                  !Sub "${NetworkingStack}PublicSubnetIds"
      PlatformVersion: LATEST
      PropagateTags: SERVICE
      ServiceConnectConfiguration:
        Enabled: true
        Namespace: "Crud"
      # Todo for logging
      # LogConfiguration
        Services:
          - DiscoveryName: backend-flask
            PortName: backend-flask
            ClientAliases:
                - Port: !Ref ContainerPort
      #ServiceRegistries:
      #  - RegistryArn: !Sub 'arn:aws:servicediscovery:${AWS::Region}:${AWS::AccountId}:service/srv-cruddur-backend-flask'
      #    ContainerPort: !Ref ContainerPort
      #    Port: !Ref ContainerPort
      #    ContainerName: 'backend-flask'
      ServiceName: !Ref ServiceName
      TaskDefinition: !Ref TaskDefinition

  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Ref TaskFamily
      ExecutionRoleArn: !GetAtt ExecutionRole.Arn
      TaskRoleArn: !GetAtt TaskRole.Arn
      NetworkMode: 'awsvpc'
      Cpu: !Ref ServiceCpu
      Memory: !Ref ServiceMemory
      RequiresCompatibilities:
        - FARGATE
      ContainerDefinitions:
        - Name: xray
          Image: public.ecr.aws/xray/aws-xray-daemon
          Essential: true
          User: "1337"
          PortMappings:
            - Name: xray
              ContainerPort: 2000
              Protocol: udp
        - Name: backend-flask
          Image: !Ref EcrImage
          Essential: true
          HealthCheck:
            Command:
              - "CMD-SHELL"
              - "python /backend-flask/bin/flask/health-check"
            Interval: 30
            Timeout: 5
            Retries: 3
            StartPeriod: 60
          PortMappings:
            - Name: !Ref ContainerName
              ContainerPort: !Ref ContainerPort
              Protocol: tcp
              AppProtocol: http
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: cruddur
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: !Ref ServiceName
          Environment:
            - Name: OTEL_SERVICE_NAME
              Value: !Ref EnvOtelServiceName
            - Name: OTEL_EXPORTER_OTLP_ENDPOINT
              Value: !Ref EnvOtelExporterOtlpEndpoint
            - Name: AWS_COGNITO_USER_POOL_ID
              Value: !Ref EnvAwsCognitoUserPoolId
            - Name: AWS_COGNITO_USER_POOL_CLIENT_ID
              Value: !Ref EnvAwsCognitoUserPoolClientId
            - Name: FRONTEND_URL
              Value: !Ref EnvFrontEnd
            - Name: BACKEND_URL
              Value: !Ref EnvBackEnd
            - Name: AWS_DEFAULT_REGION
              Value: !Ref AWS::Region
          Secrets:
            - Name: AWS_ACCESS_KEY_ID
              ValueFrom: !Ref SecretsAwsAccessKeyId
            - Name: AWS_SECRET_ACCESS_KEY
              ValueFrom: !Ref SecretsAwsSecretAccessKey
            - Name: CONNECTION_URL
              ValueFrom: !Ref SecretsConnectionUrl
            - Name: ROLLBAR_ACCESS_TOKEN
              ValueFrom: !Ref SecretsRollbarAccessToken
            - Name: OTEL_EXPORTER_OTLP_HEADERS
              ValueFrom: !Ref SecretsOtelExporterOtlpHeaders

  ExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: CrdExecutionRole
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: 'ecs-tasks.amazonaws.com'
            Action: 'sts:AssumeRole'
      Policies:
        - PolicyName: 'cruddur-execution-policy'
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Sid: 'VisualEditor0'
                Effect: 'Allow'
                Action:
                  - 'ecr:GetAuthorizationToken'
                  - 'ecr:BatchCheckLayerAvailability'
                  - 'ecr:GetDownloadUrlForLayer'
                  - 'ecr:BatchGetImage'
                  - 'logs:CreateLogStream'
                  - 'logs:PutLogEvents'
                Resource: '*'
              - Sid: 'VisualEditor1'
                Effect: 'Allow'
                Action:
                  - 'ssm:GetParameters'
                  - 'ssm:GetParameter'
                Resource: !Sub 'arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/cruddur/${ServiceName}/*'
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

  TaskRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: CrdServiceTaskRole
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: 'ecs-tasks.amazonaws.com'
            Action: 'sts:AssumeRole'
      Policies:
        - PolicyName: Cruddur-Task-Policy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Sid: VisualEditor0
                Effect: Allow
                Action:
                  -  ssmmessages:CreateControlChannel
                  -  ssmmessages:CreateDataChannel
                  -  ssmmessages:OpenControlChannel
                  -  ssmmessages:OpenDataChannel
                Resource: "*"
      ManagedPolicyArns:
        - "arn:aws:iam::aws:policy/CloudWatchFullAccess"
        - "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"

#Outputs:
#  ServiceSecurityGroupId:
#    Value: !GetAtt  ServiceSG.GroupId
#    Export:
#      Name: !Sub "${AWS::StackName}ServiceSecurityGroupId"
```

 create a bash script called service-deploy under /bin/cfn

```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/service/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/service/config.toml"
echo $CONFIG_PATH

cfn-lint $CFN_PATH

BUCKET=$(cfn-toml key deploy.bucket -t $CONFIG_PATH)
REGION=$(cfn-toml key deploy.region -t $CONFIG_PATH)
STACK_NAME=$(cfn-toml key deploy.stack_name -t $CONFIG_PATH)
#PARAMETERS=$(cfn-toml params v2 -t $CONFIG_PATH)



aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file $CFN_PATH \
  --s3-bucket $BUCKET \
  --region $REGION \
  --no-execute-changeset \
  --tags group=cruddur-backend-flask \
  --capabilities CAPABILITY_NAMED_IAM \
  # --parameter-overrides $PARAMETERS \
```



## CFN RDS Template



In this part, we will be creating the RDS database layer

First, create a file called `template.yaml` under `/aws/cfn/db`

```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: |
  Database in RDS Postgres component for the application
  - RDS Instance
  - Database Security Group
  - DB Subnetgroup

Parameters:
  NetworkingStack:
    Type: String
    Description: This is the base layer of networking components
    Default: CrdNet
  ClusterStack:
    Type: String
    Description: This is the Cluster Layer 
    Default: CrdCluster
  BackupRetentionPeriod:
    Type: Number
    Default: 0
  DBInstanceClass:
    Type: String
    Default: db.t4g.micro
  DBInstanceIdentifier:
    Type: String
    Default: cruddur-instance
  DBName:
    Type: String
    Default: cruddur
  DeletionProtection:
  #set this in on true for production
    Type: String
    AllowedValues:
         - true
         - false
    Default: false
  EngineVersion:
    Type: String
    #  DB Proxy only supports very specific versions of Postgres
    #  https://stackoverflow.com/questions/63084648/which-rds-db-instances-are-supported-for-db-proxy
    Default: '15.3'
  MasterUsername:
    Type: String

  MasterUserPassword:
    Type: String
    NoEcho: true 

Resources:
  RDSPostgresSG:
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group.html
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub "${AWS::StackName}RDSSG"
      GroupDescription: Security Group RDS
      VpcId:
        Fn::ImportValue:
          !Sub ${NetworkingStack}VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          SourceSecurityGroupId:
            Fn::ImportValue:
              !Sub ${ClusterStack}ServiceSecurityGroupId
          FromPort: 5432
          ToPort: 5432
          Description: Security Group Cluster
  DBSubnetGroup:
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-rds-dbsubnetgroup.html
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupName: !Sub "${AWS::StackName}DBSubnetGroup"
      DBSubnetGroupDescription: !Sub "${AWS::StackName}DBSubnetGroup"
      SubnetIds: { 'Fn::Split' : [ ','  , { "Fn::ImportValue": { "Fn::Sub": "${NetworkingStack}PublicSubnetIds" }}] }
  

  Database:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-rds-dbinstance.html
    Type: AWS::RDS::DBInstance
    # Remember to change this back to snapshot for production
    # cant use !Ref on DeletionPolicy and Condition Stacks
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html
    #DeletionPolicy: 'Snapshot'
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-updatereplacepolicy.html
    #UpdateReplacePolicy: 'Snapshot'
    Properties:
      AllocatedStorage: '20'
      AllowMajorVersionUpgrade: true
      AutoMinorVersionUpgrade: true
      BackupRetentionPeriod: !Ref  BackupRetentionPeriod
      DBInstanceClass: !Ref DBInstanceClass
      DBInstanceIdentifier: !Ref DBInstanceIdentifier
      DBName: !Ref DBName
      DBSubnetGroupName: !Ref DBSubnetGroup
      DeletionProtection: !Ref DeletionProtection
      EnablePerformanceInsights: true
      Engine: postgres
      EngineVersion: !Ref EngineVersion


# Must be 1 to 63 letters or numbers.
# First character must be a letter.
# Can't be a reserved word for the chosen database engine.
      MasterUsername:  !Ref MasterUsername
      # Constraints: Must contain from 8 to 128 characters.
      MasterUserPassword: !Ref MasterUserPassword
      PubliclyAccessible: true
      VPCSecurityGroups:
        - !GetAtt RDSPostgresSG.GroupId
#Outputs:
#  ServiceSecurityGroupId:
#    Value: !GetAtt ServiceSG.GroupId
#    Export:
#      Name: !Sub "${AWS::StackName}ServiceSecurityGroupId"
```

 create a bash script called service-deploy under /bin/cfn

```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)


CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/db/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/db/config.toml"
echo $CONFIG_PATH

cfn-lint $CFN_PATH

BUCKET=$(cfn-toml key deploy.bucket -t $CONFIG_PATH)
REGION=$(cfn-toml key deploy.region -t $CONFIG_PATH)
STACK_NAME=$(cfn-toml key deploy.stack_name -t $CONFIG_PATH)
PARAMETERS=$(cfn-toml params v2 -t $CONFIG_PATH)


aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file $CFN_PATH \
  --s3-bucket $BUCKET \
  --region $REGION \
  --no-execute-changeset \
  --tags group=cruddur-database \
  --parameter-overrides $PARAMETERS MasterUserPassword=$DB_PASSWORD \
  --capabilities CAPABILITY_NAMED_IAM
```
Note: In the bin file, the `DB_PASSWORD` env var is passed.For example, if you need to pass another  value you can do something like this: 
```bash
--parameter-overrides $PARAMETERS MasterUserPassword=$DB_PASSWORD MyKey3=MyValue3 \
```

launch the following command to generate a random password for rds 
```bash
export DB_PASSWORD=$(aws secretsmanager get-random-password \
--exclude-punctuation \
--password-length 41 --require-each-included-type \
--output text \
--query RandomPassword)

echo $DB_PASSWORD

#save the env var on gitpod
gp env MasterUserPassword=$DB_PASSWORD
```
Note: if you are using VSCode Local and you dont save the variable generated using the script above, make sure to relaunch it again  as you might have error regarding the master password blank

Create the file config.toml under the aws/cfn/db
```s
[deploy]
bucket = 'cfn-artifacts-39r1pe'
region = 'eu-west-2'
stack_name = 'CrdDB'

[parameters]
NetworkingStack = 'CrdNet'
ClusterStack = 'CrdCluster'
MasterUsername = 'cruddurroot'
```

## CFN DYNAMODB USING SAM

In this part, we will be creating the Dynamodb using SAM

If you are installing locally, follow the [link](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) to install sam in your machine. 



If you are using Gitpod, insert the following code on you `gipod.yml` file

```yaml
  - name: aws-sam
    init: |
      cd /workspace
      wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
      unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
      sudo ./sam-installation/install
      cd $THEIA_WORKSPACE_ROOT
```

Create a file called `template.yaml` under `/aws/cfn/ddb`

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: |
  - DynamoDB Table
  - DynamoDB Stream

Parameters:
  PythonRuntime:
    Type: String
    Default: python3.10
  MemorySize:
    Type: String
    Default: 128
  Timeout:
    Type: Number
    Default: 3
Resources:
  DynamoDBTable:
    #https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html
    Type: AWS::DynamoDB::Table
    Properties: 
      AttributeDefinitions:
        - AttributeName: message_group_uuid
          AttributeType: S
        - AttributeName: pk
          AttributeType: S
        - AttributeName: sk
          AttributeType: S
      TableClass: STANDARD
      KeySchema: 
        - AttributeName: pk
          KeyType: HASH
        - AttributeName: sk
          KeyType: RANGE
      ProvisionedThroughput:
        ReadCapacityUnits: 5
        WriteCapacityUnits: 5
      BillingMode: PROVISIONED
      # active in production
      DeletionProtectionEnabled: false
      GlobalSecondaryIndexes:
          - IndexName: message-group-sk-index
            KeySchema:
                  - AttributeName: message_group_uuid
                    KeyType: HASH
                  - AttributeName: sk
                    KeyType: RANGE
            Projection:
                  ProjectionType: ALL
            ProvisionedThroughput: 
              ReadCapacityUnits: 5
              WriteCapacityUnits: 5
      StreamSpecification:
        StreamViewType: NEW_IMAGE
  ProcessDynamoDBStream:
    #https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-function.html
    Type: AWS::Serverless::Function
    Properties:
      #CodeUri: .
      #InlineCode:
      PackageType: Zip
      Handler: lambda_handler
      Runtime: !Ref PythonRuntime
      Role: !GetAtt ExecutionRole.Arn
      MemorySize: !Ref MemorySize
      Timeout: !Ref Timeout
      Events:
        Stream:
          Type: DynamoDB
          Properties:
            Stream: !GetAtt DynamoDBTable.StreamArn
            BatchSize: 1
            # To Check
            StartingPosition: LATEST


  LambdaLogGroup:
    Type: "AWS::Logs::LogGroup"
    Properties:
      LogGroupName: "/aws/lambda/cruddur-messaging-stream00"
      RetentionInDays: 14
  LambdaLogStream:
    Type: "AWS::Logs::LogStream"
    Properties:
      LogGroupName: !Ref LambdaLogGroup
      LogStreamName: "LambdaExecution"
  
  ExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: CrdDdbStreamExecutionRole
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: 'lambda.amazonaws.com'
            Action: 'sts:AssumeRole'
      Policies:
        - PolicyName: LambdaExecutionPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action: logs:CreateLogGroup
                Resource: !Sub "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:*"
              - Effect: Allow
                Action:
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Resource: !Sub "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:${LambdaLogGroup}:*"
              - Effect: Allow
                Action:
                  - ec2:CreateNetworkInterface
                  - ec2:DeleteNetworkInterface
                  - ec2:DescribeNetworkInterfaces
                Resource: "*"
              - Effect: Allow
                Action:
                  - lambda:InvokeFunction
                Resource: "*"
              - Effect: Allow
                Action:
                  - dynamodb:DescribeStream
                  - dynamodb:GetRecords
                  - dynamodb:GetShardIterator
                  - dynamodb:ListStreams
                Resource: "*"
```
Note: Lambda now supports python 3.10. Make sure to have this version installed in your local dev. if you have a higher version not supported by lambda, you need to create a container


Create the file config.toml under the `aws/cfn/ddb`

```s
version=0.1
[default.build.parameters]
region= "eu-west-2"

[default.package.parameters]
region= "eu-west-2"

[default.deploy.parameters]
region= "eu-west-2"
```

create the script to build, package and deploy SAM.
called the file `ddb-deploy` under the `/bin/cfn`
```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)

FUNC_DIR="$THEIA_WORKSPACE_ROOT/aws/lambdas/cruddur-messaging-stream/"
TEMPLATE_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/ddb/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/ddb/config.toml"
ARTIFACTS_BUCKET="cfn-artifacts-39r1pe"

sam validate -t $TEMPLATE_PATH

#https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-build.html
sam build \
--config-file $CONFIG_PATH \
--template-file $TEMPLATE_PATH \
--base-dir $FUNC_DIR
#--parameter-overrides \


TEMPLATE_PATH="$THEIA_WORKSPACE_ROOT/.aws-sam/build/template.yaml"
OUTPUT_TEMPLATE_PATH="$THEIA_WORKSPACE_ROOT/.aws-sam/build/packaged.yaml"
#https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-package.html
sam package \
--s3-bucket $ARTIFACTS_BUCKET \
--s3-prefix cruddur-ddb \
--config-file $CONFIG_PATH \
--output-template-file $OUTPUT_TEMPLATE_PATH \
--template-file $TEMPLATE_PATH \
--s3-prefix "ddb"

PACKAGED_TEMPLATE_PATH="$THEIA_WORKSPACE_ROOT/.aws-sam/build/packaged.yaml"
#https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-deploy.html
sam deploy \
  --template-file  $PACKAGED_TEMPLATE_PATH \
  --config-file $CONFIG_PATH \
  --stack-name "CrdDdb" \
  --tags group=cruddur-ddb \
  --no-execute-changeset \
  --capabilities CAPABILITY_NAMED_IAM

```

from the `lambdas` directory, create a new folder called `cruddur-messaging-stream`, insert there the lambda `cruddur-messaging-stream` and rename it as `lambda_handler.py
`

## CFN CICD

Create an s3 bucket for the artifacts using the following command
```sh
export RANDOM_STRING=$(aws secretsmanager get-random-password --exclude-punctuation --exclude-uppercase --password-length 6 --output text --query RandomPassword)
aws s3 mb s3://codepipeline-cruddur-artifacts-$RANDOM_STRING

export CICD_BUCKET="codepipeline-cruddur-artifacts-$RANDOM_STRING"

gp env CICD_BUCKET="codepipeline-cruddur-artifacts-$RANDOM_STRING"
```

Create the `codebuild.yaml` file under the following `aws/cfn/cicd/nested`
```yaml
AWSTemplateFormatVersion: 2010-09-09

Description: |
  Codebuild used for baking container images
  - codebuild project
  - codebuild project role

Parameters:
  LogGroupPath:
    Type: String
    Description: "The log group path for Codebuild"
    Default: "/cruddur/codebuild/bake-service"
  LogStreamName:
    Type: String
    Description: "The log group path for Codebuild"
    Default: "backend-flask"
  CodeBuildImage:
    Type: String
    Default: aws/codebuild/amazonlinux2-x86_64-standard:4.0
  CodeBuildComputeType:
    Type: String
    Default: BUILD_GENERAL1_SMALL
  CodeBuildTimeoutMins:
    Type: Number
    Default: 5
  BuildSpec:
    Type: String
    Default: 'buildspec.yaml'
Resources:
  CodeBuild:
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codebuild-project.html
    Type: AWS::CodeBuild::Project
    Properties:
      QueuedTimeoutInMinutes: !Ref CodeBuildTimeoutMins
      ServiceRole: !GetAtt CodeBuildRole.Arn
      # PrivilegedMode is needed to build Docker images
      # even though we have No Artifacts, CodePipeline Demands both to be set as CODEPIPLINE
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        ComputeType: !Ref CodeBuildComputeType
        Image: !Ref CodeBuildImage
        Type: LINUX_CONTAINER
        PrivilegedMode: true
      LogsConfig:
        CloudWatchLogs:
          GroupName: !Ref LogGroupPath
          Status: ENABLED
          StreamName: !Ref LogStreamName
      Source:
        Type: CODEPIPELINE
        BuildSpec: !Ref BuildSpec
  CodeBuildRole:
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
        - Action: ['sts:AssumeRole']
          Effect: Allow
          Principal:
            Service: [codebuild.amazonaws.com]
        Version: '2012-10-17'
      Path: /
      Policies:
        - PolicyName: !Sub ${AWS::StackName}ECRPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - ecr:BatchCheckLayerAvailability
                - ecr:CompleteLayerUpload
                - ecr:GetAuthorizationToken
                - ecr:InitiateLayerUpload
                - ecr:BatchGetImage
                - ecr:GetDownloadUrlForLayer
                - ecr:PutImage
                - ecr:UploadLayerPart
                Effect: Allow
                Resource: "*"
        - PolicyName: !Sub ${AWS::StackName}VPCPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - ec2:CreateNetworkInterface
                - ec2:DescribeDhcpOptions
                - ec2:DescribeNetworkInterfaces
                - ec2:DeleteNetworkInterface
                - ec2:DescribeSubnets
                - ec2:DescribeSecurityGroups
                - ec2:DescribeVpcs
                Effect: Allow
                Resource: "*"
              - Action:
                - ec2:CreateNetworkInterfacePermission
                Effect: Allow
                Resource: "*"
        - PolicyName: !Sub ${AWS::StackName}Logs
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - logs:CreateLogGroup
                - logs:CreateLogStream
                - logs:PutLogEvents
                Effect: Allow
                Resource:
                  - !Sub arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:${LogGroupPath}*
                  - !Sub arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:${LogGroupPath}:*
Outputs:
  CodeBuildProjectName:
    Description: "CodeBuildProjectName"
    Value: !Sub ${AWS::StackName}Project
```

create the `config.toml` under the following structure `/aws/cfn/cicd`
```s
[deploy]
bucket = 'cfn-artifacts-39r1pe'
region = 'eu-west-2'
stack_name = 'CrdCicd'

[parameters]
ClusterStack = 'CrdCluster'
ServiceStack = 'CrdSrvBackendFlask'
GitHubBranch = 'prod'
GithubRepo = 'aws-bootcamp-cruddur-2023'
```

create the `template.yaml` under the following structure `/aws/cfn/cicd`
```yaml
AWSTemplateFormatVersion: 2010-09-09

Description: |
  - Codestar Connection v2 Github
  - Codepipeline
  - Codebuild
Parameters:
  GitHubBranch:
    Type: String
    Default: prod
  GithubRepo:
    Type: String
    Default: 'dontworryjohn/aws-bootcamp-cruddur-2023'
  ClusterStack:
    Type: String
  ServiceStack:
    Type: String
  ArtifactBucketName:
    Type: String

Resources:
  CodeBuildBakeImageStack:
    Type: AWS::CloudFormation::Stack
    Properties:
         TemplateURL: nested/codebuild.yaml
  CodeStarConnection:
    Type: AWS::CodeStarConnections::Connection
    Properties:
         ConnectionName: !Sub ${AWS::StackName}-connection
         ProviderType: GitHub
  Pipeline:
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-pipeline.html
    Type: AWS::CodePipeline::Pipeline
    Properties:
      ArtifactStore:
        Location: !Ref ArtifactBucketName
        Type: S3
      RoleArn: !GetAtt CodePipelineRole.Arn
      Stages:
        - Name: Source
          Actions:
            - Name: ApplicationSource
              RunOrder: 1
              ActionTypeId:
                Category: Source
                Provider: CodeStarSourceConnection
                Owner: AWS
                Version: '1'
              OutputArtifacts:
                - Name: Source
              Configuration:
                ConnectionArn: !Ref CodeStarConnection
                FullRepositoryId: !Ref GithubRepo
                BranchName: !Ref GitHubBranch
                OutputArtifactFormat: "CODE_ZIP"
        - Name: Build
          Actions:
            - Name: BuildContainerImage
              RunOrder: 1
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              InputArtifacts:
                - Name: Source
              OutputArtifacts:
                - Name: ImageDefinition
              Configuration:
                ProjectName: !GetAtt CodeBuildBakeImageStack.Outputs.CodeBuildProjectName
                BatchEnabled: false
        # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-ECS.html
        - Name: Deploy
          Actions:
            - Name: Deploy
              RunOrder: 1
              ActionTypeId:
                Category: Deploy
                Provider: ECS
                Owner: AWS
                Version: '1'
              InputArtifacts:
                - Name: ImageDefinition
              Configuration:
                # In Minutes
                DeploymentTimeout: "10"
                ClusterName:
                  Fn::ImportValue:
                    !Sub ${ClusterStack}ClusterName
                ServiceName:
                  Fn::ImportValue:
                    !Sub ${ServiceStack}ServiceName
                    
  CodePipelineRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
        - Action: ['sts:AssumeRole']
          Effect: Allow
          Principal:
            Service: [codepipeline.amazonaws.com]
        Version: '2012-10-17'
      Path: /
      Policies:
        - PolicyName: !Sub ${AWS::StackName}EcsDeployPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - ecs:DescribeServices
                - ecs:DescribeTaskDefinition
                - ecs:DescribeTasks
                - ecs:ListTasks
                - ecs:RegisterTaskDefinition
                - ecs:UpdateService
                Effect: Allow
                Resource: "*"
        - PolicyName: !Sub ${AWS::StackName}CodeStarPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - codestar-connections:UseConnection
                Effect: Allow
                Resource:
                  !Ref CodeStarConnection
        - PolicyName: !Sub ${AWS::StackName}CodePipelinePolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - s3:*
                - logs:CreateLogGroup
                - logs:CreateLogStream
                - logs:PutLogEvents
                - cloudformation:*
                - iam:PassRole
                - iam:CreateRole
                - iam:DetachRolePolicy
                - iam:DeleteRolePolicy
                - iam:PutRolePolicy
                - iam:DeleteRole
                - iam:AttachRolePolicy
                - iam:GetRole
                - iam:PassRole
                Effect: Allow
                Resource: '*'
        - PolicyName: !Sub ${AWS::StackName}CodePipelineBuildPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                - codebuild:StartBuild
                - codebuild:StopBuild
                - codebuild:RetryBuild
                Effect: Allow
                Resource: !Join
                  - ''
                  - - 'arn:aws:codebuild:'
                    - !Ref AWS::Region
                    - ':'
                    - !Ref AWS::AccountId
                    - ':project/'
                    - !GetAtt CodeBuildBakeImageStack.Outputs.CodeBuildProjectName
```

create the script called `cicd-deploy` under `bin/cfn/cicd-deploy
```sh
#! /usr/bin/env bash
#set -e # stop execution of the script if it fails

#This script will pass the value of the main root
export THEIA_WORKSPACE_ROOT=$(pwd)

CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/cicd/template.yaml"
CONFIG_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/cicd/config.toml"
PACKAGED_PATH="$THEIA_WORKSPACE_ROOT/tmp/packaged-template.yaml"
PARAMETERS=$(cfn-toml params v2 -t $CONFIG_PATH)

echo $CONFIG_PATH

#cfn-lint $CFN_PATH

BUCKET=$(cfn-toml key deploy.bucket -t $CONFIG_PATH)
REGION=$(cfn-toml key deploy.region -t $CONFIG_PATH)
STACK_NAME=$(cfn-toml key deploy.stack_name -t $CONFIG_PATH)



# package
# -----------------
echo "== packaging CFN to S3..."
aws cloudformation package \
  --template-file $CFN_PATH \
  --s3-bucket $BUCKET \
  --s3-prefix cicd-package/ \
  --region $REGION \
  --output-template-file "$PACKAGED_PATH"


cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file "$PACKAGED_PATH" \
  --s3-bucket $BUCKET \
  --s3-prefix cruddur-cicd \
  --region $REGION \
  --no-execute-changeset \
  --tags group=cruddur-cicd \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides $PARAMETERS ArtifactBucketName=$CICD_BUCKET
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

