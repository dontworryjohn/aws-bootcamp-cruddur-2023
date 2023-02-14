
# Prelude

If you have not prepared the requirements for this bootcamp, I will suggest to check the videos that Andrew and his team put together for you.
https://www.youtube.com/playlist?list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv

You will need to register to the following services:
- Create a Github Account. You will copy Andrew's repository with the right formatting of the repo and must be public.
- Create a Gitpod account and install the extention for your browser.
- Create Github CodeSpace.
- Create the AWS account (This is the important one as you will spin all the service here). Make sure you have a credit/debit card ready.
- Create Lucidchart. This app allows you to create chart/diagram. Having a visual structure are really useful to see the overview of what are you creating.
- Create Honeycomb.io account.
- Create Rollbar account.

Once you registered with all of the services, you can go for the assignement for the week 0.


# Week 0 — Billing and Architecture

This week the team will be discussing about the billing for the services we will spin during the bootcamp.

Princing of aws services is vary depending of the region. Make sure to use the region close to you and see if all service you will utilise are available for the region.
And also make sure you set the billing allarm so you dont have unexpected cost. Since my account is more than 1 year old, I can not use anymore the free tier but I have plenty of AWS credit I can use against all services (check always if your aws credit is usable for the specific aws service)

If you are using an IAM user, make sure to attach a billing policy otherwise you wont be able to access this part of the console and you will get an error as you dont have permission.

## Info about billing alerts, Tags, Cost Explorer
In this section, we will be discussing the billing dashboard and all its component such as Cost Explorer, Billing Alerts, Tags, AWS calculator etc.

### Billing Alerts
There are 2 ways to set the billing alerts.

- Using Budget.
- Using Cloudwatch Alarm. In this case, you need to create an alarm on us-east-1 region (since it is the only region you can create an alarm). You can create up to 10 free cloudwatch alarm

Those 2 alarms will be helpful to identify if you are underspending/overspending.

### Free Tier
This section will show all the usage of your free tier. It will show all the services free for the 12 months (starting with the registration) and its usage and forcast. After the 12 months, they are still some services are always free.
And also there are some service are "Trial" which means that is available for a short period such as 30 days.

### Tags
Tags (are Key/Value pair) are useful when you want to know how your cost is allocated. For example if your want to identify all the services you used under the tag enviromenrt: dev (for example)

### Cost Explorer
Cost explorer is a service which visualise, understand and manage your AWS costs usage over time.

### Report
The section report allows to generate reports. there are some reports already created by AWS that you can use

### Credit
This is the section when you submit your credit that you have obtain during an event (for example after submitting a feedback questionnaires). And also it shows when the expiration date.

### AWS Calculator
This is a tool where you want to estimate the cost of one or more services. Useful when someone asks you to give an estimate cost of the service you are going to use. I used this tool in several learning plan during the Skillbuilder.
https://calculator.aws/#/

# Architecture Diagram

The image below is the architecture of the micro bloggin app


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
Important thing when it come to security. Always inform the business of the techcnical risk that can exist for open vulnerabilties that has not resolved and can potentially can affect the business and how will be solved.

### Definition of the cloud security

Cybersecurity that protects data, application and services associated with cloud enviroments from both external and inerla security threats.


