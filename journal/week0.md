
# Prelude

If you have not prepared the requirements for this boot camp, I will suggest checking the videos that Andrew and his team put together for you.
https://www.youtube.com/playlist?list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv

You will need to register for the following services:
- Create a Github Account. You will copy Andrew's repository with the right formatting of the repo and must be public.
- Create a Gitpod account and install the extension for your browser.
- Create Github CodeSpace.
- Create the AWS account (This is the important one as you will spin all the services here). Make sure you have a credit/debit card ready.
- Create Lucidchart. This app allows you to create chart/diagrams. Having a visual structure is useful to see the overview of what are you creating.
- Create Honeycomb.io account.
- Create Rollbar account.

Once you registered with all of the services, you can go for the assignment for week 0.


# Week 0 — Billing, Architecture, Security

This week the team will be discussing the billing architecture security.

The pricing of aws services is vary depending on the region. Make sure to use the region close to you and see if all services you will utilise are available for the region.
And also make sure you set the billing alarm so you don't have unexpected costs. Since my account is more than 1 year old, I can not use anymore the free tier but I have plenty of AWS credit I can use against all services (check always if your aws credit is usable for the specific aws service)

If you are using an IAM user, make sure to attach a billing policy otherwise you won't be able to access this part of the console and you will get an error as you don't have permission.

## Info about billing alerts, Tags, Cost Explorer
In this section, we will be discussing the billing dashboard and all its components such as Cost Explorer, Billing Alerts, Tags, AWS calculator etc.

### Billing Alerts
There are 2 ways to set the billing alerts.

- Using Budget.
- Using Cloudwatch Alarm. In this case, you need to create an alarm on us-east-1 region (since it is the only region you can create an alarm). You can create up to 10 free cloudwatch alarm

Those 2 alarms will be helpful to identify if you are underspending/overspending.

### Free Tier
This section will show all the usage of your free tier. It will show all the services free for the 12 months (starting with the registration) and their usage and forecast. After 12 months, they are still some services that are always free.
And also there is some service that is "Trial" which means that is available for a short period such as 30 days.

### Tags
Tags (are Key/Value pair) are useful when you want to know how your cost is allocated. For example, if your want to identify all the services you used under the tag environment: dev (for example)

### Cost Explorer
Cost explorer is a service which visualises, understands and manages your AWS costs usage over time.

### Report
The section report allows for generating reports. there are some reports already created by AWS that you can use

### Credit
This is the section where you submit the credit that you have to obtain during an event (for example after submitting a feedback questionnaire). And also it shows when the expiration date.

### AWS Calculator
This is a tool where you want to estimate the cost of one or more services. Useful when someone asks you to give an estimated cost of the service you are going to use. I used this tool during some exercises on skillbuilder.

https://calculator.aws/#/

# Architecture Diagram

The image below is the architecture of the micro blogging app


## Requirements
- Application using micro services
- The frontend is in JS and the backend is in Python
- Using api to communicate
- Authetnication using Cognito
- Use as much as possible the aws free tier
- Momento as a third party caching system

![Architecture image](https://raw.githubusercontent.com/dontworryjohn/aws-bootcamp-cruddur-2023/main/Blank%20diagram.jpeg)

To view the chart please check the following link https://lucid.app/lucidchart/0916f541-fda7-4be3-b13d-9c4f6b2200a3/edit?viewport_loc=-535%2C-57%2C3383%2C1508%2C0_0&invitationId=inv_f913a5bf-8fe4-43b1-86ea-060bde784dfb



# Security
The important thing when it comes to security. Always inform the business of the techcnical risk that can exist of open vulnerabilties that has not resolved and can potentially can affect the business and how will be solved.

### Definition of the cloud security
Cybersecurity that protects data, application and services associated with cloud enviroments from both external and internal security threats.

### Why care about cloud security
- Reducing the impact of breach
- Protecting all the system (application, network etc) against malicious data theft
- Reducing the human error responsible for data leaks

### Cloud Security requires practice
- Understand the complexity of the system
- Always keep updated with the new services announced
- Bad hackers are improving as well.



#### MFA for root account
Root user is the most powerful user in aws environment. I consider it the key to your kingdom. Once it is compromised, hackers can spin any services on your AWS account (for example creating a bitcoin mining)
Enable the MFA for the root account gives you an extra layer of security.
Could be virtual or physical.

#### AWS Organization
Create an organization unit (AWS Organization)
AWS Organization allows you to create and manage multiple account. Also it allows to apply governance policies to accounts or group.
There are 2 approce to create the organization:
- Creating business unit (HR Ou, Finance Ou, Engineering Ou)
- Creating a Standby and Active Pool. 

SCP (Service Control Policy) are a type of organisational policy that you can use to manage permission in your organisation.

#### AWS Cloud Trail
Auditing Service in AWS. Most all the api will be recorded in this service.
Cloudtrail will record only the activity in the region you will operate.
This service is not free

#### IAM 
Ability to access using user and password 3 kinds of users:
- IAM user with user and password (make sure MFA is active as well as you activated on root account)
- Federated user are users federated from an on-premise environment without a password
- Web Token User

Always Give the least privilege to the users. Don't give more than what it is necessary.

When you are working on AWS, it is a best practice to use the IAM user instead of the Root account.
If for some reason the IAM user is compromised, it is simple to solve the problem by removing the policy attached to it/deleting the user himself.

Policies are assigned to either a IAM user or IAM role or IAM group and consist of what the entity can/can not do. For example, a policy could be the possibility to read the content of the s3 bucket.

Access Key and Secret Access key are similar to the user and password (keep it always secret). One reason you need to use it is for example you need to do some calls using CLI. Never hardcode this information on services that it is public expose (for example code on github with access key and secret access key) as bad actors could reuse those access to do bad actions (exploit your application and get sensible information or spin services)In some cases you need to use an IAM Role and attach it to a service or even a user. the difference between Iam user and Iam role is once the entity assumes the IAM role, it is valid for a short time and temporarily loses the previous privilege.

Make sure to create the IAM role as simply as possible.

### Share Responsibility
This diagram shows what is the responsibility of the customer and what is the responsibility of AWS.
For example, AWS is responsible for the global infrastructure. It takes care of everything works accordingly and is secure. Meanwhile, the customer is responsible for the application, eventually configuration (NACL/SG), and encryption at rest and in transit.



![Share responsibility](https://d1.awsstatic.com/security-center/Shared_Responsibility_Model_V2.59d1eccec334b366627e9295b304202faf7b899b.jpg)