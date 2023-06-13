# Week 10 — CloudFormation Part 

This week the team will be talking about Cloudformation.

## Cost
In Cloudformation, you only pay for what you use, with no minimum fees and no required upfront commitment.
If you are using a registry extension with cloudformation, you incur charges per handler operation.,
Handler operations are: `CREATE`, `UPDATE`, `DELETE`, `READ`, or `LIST` actions on a resource type and `CREATE`, `UPDATE`, or `DELETE` actions for Hook type.

## Security

## CFN Implementation

create a file called `template.yaml`  under the `aws/cfn`

```yaml
AWSTempleteFormatVersion: 2010-09-09
Description: |
    Setup ECS Cluster

#Parameters:
#Mappings:
#Resources:
#Outputs:
#Metadata







```


### Reference

- [AWS Cloudformation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

