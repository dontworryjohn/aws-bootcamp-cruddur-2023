# Week 3 — Decentralized Authentication

This week the team will be talking about Decentralized Authentication, in particular, Amazon Cognito

## Security Amazon Cognito

 1 Place for your credentials

 
 SAML (Security Assertion Markup Language): Single point of logging into any application. An example is the faceid which you use the face to log in instead of your credential. this is used for authentication
 OpenID Connect: allows you to connect using your social media credential (using google credential, LinkedIn Facebook etc.) rather than creating a new username and password. this is used for authentication
 OAuth: Use for authorization

What is Decentralised Authentication?
Decentralised authentication is an extension of the concept of services above. If you want to compare is some sort of password manager that you can use in different application
 
 Amazon Cognito is an aws service that allows users to authenticate. credentials are stored in cognito. it is similar of a directory under the aws hood.

 **Amazon Cognito User Pool**
 ![Amazon Cognito User Pool](https://td-mainsite-cdn.tutorialsdojo.com/wp-content/uploads/2020/05/Cognito-User-Pool-for-Authentication.png)

 **Cognito Identity Pool**
  ![Cognito Identity Pool](https://td-mainsite-cdn.tutorialsdojo.com/wp-content/uploads/2020/05/Cognito-Identity-Pools-Federated-Identities.png)


  # Troubleshoot

  ###how to force password change for your user created in cognito

 aws cognito-idp admin-set-user-password --username nameofusername --password Testing1234! --user-pool-id "${AWS_USER_POOLS_ID}" --permanent





