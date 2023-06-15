# Week 10 — CloudFormation Part 

This week the team will be talking about Cloudformation.

## Cost
In Cloudformation, you only pay for what you use, with no minimum fees and no required upfront commitment.
If you are using a registry extension with cloudformation, you incur charges per handler operation.,
Handler operations are: `CREATE`, `UPDATE`, `DELETE`, `READ`, or `LIST` actions on a resource type and `CREATE`, `UPDATE`, or `DELETE` actions for Hook type.

## Security

## CFN Implementation

create a file called `template.yaml`  under the `aws/cfn` with the following struture

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
- Some aws services wants the extension `.yml`. An example is `buildspec` (codebuild). Other service like cloudformation wants the `.yaml` exstension.
- For some sample, you can reference the  [aws templates](https://aws.amazon.com/cloudformation/resources/templates/)

To deploy the cloudformation, create a folder called  `cfn` and inside call the script `deploy`
```bash
#! /usr/bin/env bash
set -e # stop execution of the script if it fails

CFN_PATH="$THEIA_WORKSPACE_ROOT/aws/cfn/template.yaml"

cfn-lint $CFN_PATH
aws cloudformation deploy \
  --stack-name "my-cluster" \
  --template-file $CFN_PATH \
  --s3-bucket "cfn-artifacts-randomname" \
  --no-execute-changeset \
  --capabilities CAPABILITY_NAMED_IAM

```
Note: 
- the   `--no-execute-changeset` will validate the code but not execute it.
- Once you run the command, the cli will create a script to check the out come. you can use the code generated or check it on the cloudformation via console.
- changeset in the console is useful to understand the behaviour of the change and to see if there is a differnet in your infrastructure (i.e a critical database run in production. By seeing changeset you know if the resource will be removed). check also the Update requires voice in the [documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-service.html)
- check the tab `replacement` if it is `true`. this helps to see if one part of the stack will be replaced.

from the aws console, check the stack deploy and if what you have deployed.click on `execute change set`

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

Note: cfn-guard is an open-source command line interface (CLI) that checks CloudFormation templates for policy compliance using a simple, policy-as-code, declarative language. for more details refer to the followin [link](https://github.com/aws-cloudformation/cloudformation-guard)

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

create a bucket in the region called `cfn-artifacts-randomname` in the same region where is your service. in my case in eu-west-2





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

