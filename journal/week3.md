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

Please  click [here](https://scribehow.com/shared/How_to_Create_a_User_Pool_in_AWS_Cognito__KfU7GrqHS2ex3SW-xNLcSw) to create the user pool using the console

# Configuration Amplify

 Using the terminal go to the dictory by typing the following command:
``` 
cd front-react-js 
npm i aws-amplyfy --save
```
this command will install amplify library and  will be added to the package.json

from the **app.js**, add the following codes:
```
import { Amplify } from 'aws-amplify';

Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_APP_AWS_PROJECT_REGION,
  //"aws_cognito_identity_pool_id": process.env.REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_APP_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_AWS_USER_POOLS_WEB_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```

from the **docker-compose.yml** on the frontend-react-js under environment:, add the following code
```
REACT_APP_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}"
REACT_APP_AWS_COGNITO_REGION: "${AWS_DEFAULT_REGION}"
REACT_APP_AWS_USER_POOLS_ID: "${AWS_USER_POOLS_ID}"
REACT_APP_CLIENT_ID: "${APP_CLIENT_ID}"
```
Make sure to create the env var  **AWS_USER_POOLS_ID** and **APP_CLIENT_ID** on gitpod and codespace. (N.B: Since these env vars have not been loaded during the booting, you might get an error. either you rebuild your workspace or you pass the variable via the terminal. I do not hardcode the env vars for security reasons and for simplicity)
The AWS_USER_POOLS_ID and APP_CLIENT_ID you find when you configure the cognito user pool.


# Showing the components based on logged in/logged out

from the **homefeedpage.js** insert the following command
```
import { Auth } from 'aws-amplify';
```

this instruction is already implemented so you can skip this part
```
const [user, setUser] = React.useState(null);
```

delete the code with the  cookies 
```
  const checkAuth = async () => {
    console.log('checkAuth')
    // [TODO] Authenication
    if (Cookies.get('user.logged_in')) {
        display_name: Cookies.get('user.name'),
        handle: Cookies.get('user.username')
    }
  };
```

and replace with the following that used cognito
```
// check if we are authenicated
const checkAuth = async () => {
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((user) => {
    console.log('user',user);
    return Auth.currentAuthenticatedUser()
  }).then((cognito_user) => {
      setUser({
        display_name: cognito_user.attributes.name,
        handle: cognito_user.attributes.preferred_username
      })
  })
  .catch((err) => console.log(err));
};

```

this instruction is already implemented so you can skip this part
```
// check when the page loads if we are authenicated
React.useEffect(()=>{
  loadData();
  checkAuth();
}, [])
```

This instruction is already implemented so you can skip this part as well.
```
<DesktopNavigation user={user} active={'home'} setPopped={setPopped} />
<DesktopSidebar user={user} />
```
On profileinfo.js, delete the following code
```
import Cookies from 'js-cookie'
```
and replace with the following
```
import { Auth } from 'aws-amplify';
```

remove the following code
```
    console.log('signOut')
    // [TODO] Authenication
    Cookies.remove('user.logged_in')
    //Cookies.remove('user.name')
    //Cookies.remove('user.username')
    //Cookies.remove('user.email')
    //Cookies.remove('user.password')
    //Cookies.remove('user.confirmation_code')
    window.location.href = "/"
```

and we replace with the new signout
```
const signOut = async () => {
    try {
        await Auth.signOut({ global: true });
        window.location.href = "/"
    } catch (error) {
        console.log('error signing out: ', error);
}
```

# Implementation of the logging page




# Troubleshoot

  ###how to force password change for your user created in cognito

 aws cognito-idp admin-set-user-password --username nameofusername --password Testing1234! --user-pool-id "${AWS_USER_POOLS_ID}" --permanent





