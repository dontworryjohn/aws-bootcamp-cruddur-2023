# Week 3 — Decentralized Authentication

This week the team will be talking about Decentralized Authentication, in particular, Amazon Cognito

# Security Amazon Cognito

 1 Place for your credentials

- SAML (Security Assertion Markup Language): Single point of logging into any application. An example is the faceid which you use the face to log in instead of your credential. this is used for authentication
-  OpenID Connect: allows you to connect using your social media credential (using google credential, LinkedIn Facebook etc.) rather than creating a new username and password. this is used for authentication
- OAuth: Use for authorization

What is Decentralised Authentication?
Decentralised authentication is an extension of the concept of services above. If you want to compare is some sort of password manager that you can use in different application
 
 Amazon Cognito is an aws service that allows users to authenticate. credentials are stored in cognito. it is similar of a directory under the aws hood.

 **Amazon Cognito User Pool**
 ![Amazon Cognito User Pool](https://td-mainsite-cdn.tutorialsdojo.com/wp-content/uploads/2020/05/Cognito-User-Pool-for-Authentication.png)

 **Cognito Identity Pool**
  ![Cognito Identity Pool](https://td-mainsite-cdn.tutorialsdojo.com/wp-content/uploads/2020/05/Cognito-Identity-Pools-Federated-Identities.png)

Reason for using Amazon Cognito
- User directory for Customer
- Ability to access aws resources for the application being built
- Identity broker for AWS Resources with temporary credentials
- It can extend users to AWS Resources easily.

# Cost
This Week Cirag did not post any video about cost so I did some research this is what I found:
> The Cognito Your User Pool feature has a free tier of 50,000 MAUs ( monthly active users) per account for users who sign in directly to Cognito User Pools and 50 MAUs for users federated through SAML 2.0 based identity providers. The free tier does not automatically expire at the end of your 12 month AWS Free Tier term, and it is available to both existing and new AWS customers indefinitely. Please note - the free tier pricing isn’t available for both Your User Pool feature and SAML or OIDC federation in the AWS GovCloud regions.

For reference click [Here](https://aws.amazon.com/cognito/pricing/).

# Setup Cognito User Pool

Please follow the configuration on [here](https://scribehow.com/shared/How_to_Create_a_User_Pool_in_AWS_Cognito__KfU7GrqHS2ex3SW-xNLcSw)

# Troubleshoot

  ###how to force password change for your user created in cognito

 aws cognito-idp admin-set-user-password --username nameofusername --password Testing1234! --user-pool-id "${AWS_USER_POOLS_ID}" --permanent





