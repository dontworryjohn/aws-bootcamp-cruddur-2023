# Week 9 — CI/CD with CodePipeline, CodeBuild and CodeDeploy

This week the team will be talking about CI/CD Pipeline.

-  [Cost](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week9.md#cost)
- [Security](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week9.md#security)
- [CICD Implementation](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/journal/week9.md#implementation-codepipeline)

# Cost

CodeCommit: Depending on the number of users, AWS does not charge if you have 5 active users. If you pass the limit, the cost is $1 every month.
AWS offers the following:

For the first 5 Acive users
- 5,000 repositories per account; up to 25,000 upon request
- 50 GB-month of storage
- 10,000 Git requests/month

for each additional user beyond the first 5
5,000 repositories per account; up to 25,000 upon request
10 GB-month of storage per active user
2,000 Git requests/month per active user

Codebuild: Pay as you go model price depending on execution time.

Codedeploy: There is no additional charge for code deployments to Amazon EC2. If you deploy to on premises servers, the cost is $0.02 per on-premises server update.

CodePipeline: Free tier allows to have 1 active pipeline per month. AWS charges $1 per active pipeline per month (for example if you have 3 pipelines but 1 has code, you will be charged for 1). You could incur to extra costs such as s3 or trigger extra cost

# Security

## Amazon Side - Security Best Practice

- Business compliance: It means that a company adheres to the applicable rules and laws. For example, the service must be available within the scope region.

- Amazon Organization SCP: restrict the actions of who can create, delete, and modify the production CI/CD pipeline. For Example limiting the number of users, setting role vs IAM users

- AWS CloudTrail: monitoring to trigger alerts for malicious activities (e.i changes to the Production Pipeline)

- GuardDuty is enabled for monitoring suspicious DNS comms and automated for autoremediation

- AWS Config Rules is enabled in the account and region of CodeBuild

## Application Side - Security Best Practice

- Access Control: Roles and IAM users with the least privilege for making changes in the CICD pipeline.

- Security of the CICD pipeline: For example, if secrets are being shared and/or if the secret manager is being used, the integrity of the container registry and therefore it  is not tampered with, controlling a none AWS CICD pipeline (vulnerability)

- Security in the CICD pipeline: Use of tools such as SCA, SAST, Secret Scanner, DAST implemented in the CICD pipeline 

- Security of the CICD pipeline entry points: Make sure there is no way to bypass the CICD to make production changes

- Enable Encryption in Transit using TLS/SSL certification

- Use trusted source control (for example Github) for sending changes to the CICD pipeline

- Develop a process for continuously verifying if there is a change that may compromise the known state of a CICD pipeline

## Implementation Codepipeline

In this implementation, we want to automate the process of deploying our code rather than doing it all manually.
The services that we will be using are Codepipeline and CodeBuilding.
When the code is merged from main branch to the prod branch, the pipeline will be triggered.

Find below the diagram:
![codepipeline](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/codepipeline.jpg?raw=true)



Create first the `buildspec.yml` under the `backend-flask`:

```yaml
# Buildspec runs in the build stage of your pipeline.
version: 0.2
phases:
  install:
    commands:
      - echo "cd into $CODEBUILD_SRC_DIR/backend-flask"
      - cd $CODEBUILD_SRC_DIR/backend-flask
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $IMAGE_URL
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -f Dockerfile.prod -t backend-flask .
      - docker tag $REPO_NAME $IMAGE_URL/$REPO_NAME
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image..
      - docker push $IMAGE_URL/$REPO_NAME
      - cd $CODEBUILD_SRC_DIR
      - echo "imagedefinitions.json > [{\"name\":\"$CONTAINER_NAME\",\"imageUri\":\"$IMAGE_URL/$REPO_NAME\"}]" > imagedefinitions.json
      - printf "[{\"name\":\"$CONTAINER_NAME\",\"imageUri\":\"$IMAGE_URL/$REPO_NAME\"}]" > imagedefinitions.json

env:
  variables:
    AWS_ACCOUNT_ID: 238967891447
    AWS_DEFAULT_REGION: eu-west-2
    CONTAINER_NAME: backend-flask
    IMAGE_URL: 238967891447.dkr.ecr.eu-west-2.amazonaws.com
    REPO_NAME: backend-flask:latest
  

artifacts:
  files:
    - imagedefinitions.json
```

Note: In the variable sections, change `AWS_ACCOUNT_ID` and `AWS_DEFAULT_REGION` with your account id and your region

Created also a branch called `prod`. You will need this during the creation of the Codepipeline

Follow the [link](https://scribehow.com/shared/How_to_Create_a_CodePipeline_with_AWS_and_GitHub__8ogyyQ1nRRus4U2EpRF1Jw) to create the codepipeline and the codebuild

Make sure to attach a policy to the `Codebuild role` with the following json policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRPermissions",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:BatchDeleteImage"
            ],
            "Resource": "*"
        }
    ]
}
```

To test if our pipeline works when changes are commited, from `app.py` modify the health-check with the following
```py
@app.route('/api/health-check')
def health_check():
  return {'success': True, 'ver': 1}, 200
```

Once it is commited to the main, merge it to the `prod `branch` and wait once the image is deployed on your ecs backend flask.

If everything works fine, you will have an image similar of this
![codepipeline](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/codepipeline.jpg?raw=true)