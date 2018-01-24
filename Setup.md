# One time setup

The steps were last run in January 2018.

## 1. Create an AWS User

This step is only required if you do not already have an IAM user with programmatic access to AWS.

**Steps**:
1. In the AWS console, go to the IAM section (Identity and Access Management).
2. On the left hand menu, click on `Users`.
3. Click the `Add User` button.
4. Add a user name (e.g., `fastai`), and enable `Programmatic access`.
5. Set the permissions for this user, and click next.
    * If you don't have any permission groups, create one.
    * The simplest and least secure thing you can do is create a group that has full administrator access.
    * If you are using an account with multiple users, it is not advisable to create a group with full admin access.
6. Review the settings, and click `Create user`.
7. After the user has been created, you can see the access key and secret. Keep a note of both of these.
    * There is also an option to download these values as a `credentials.csv` file.

## 2. Request Limit Increase

The default limit for creating `p2.xlarge` instance types is 0. To increase this limit:

**Steps**:
1. In the AWS console, go to the EC2 dashboard.
2. On the left hand menu, click on `Limits`.
3. Click on `Request limit increase` on any instance type; they all take you to the same place.
    * You will be taken to the `Create Case` section of the `Support Center`.
4. Complete the form as follows:
    * Regarding: `Service Limit Increase`
    * Limit type: `EC2 Instances`
    * Region: (your preferred region)
    * Primary Instance Type: `p2.xlarge`
    * Use Case Description: `fast.ai MOOC`
    * Contact method: `Web`
5. Click `Submit`. If you set your use case description as above, the authorisation reply should be immediate. The email you will receive may state that: "It can sometimes take up to 30 minutes for this to propagate and become available for use."
    
## 3. Configure the AWS Command Line Interface

**Pre-Requisite**:
* You have a bash terminal and have `awscli` installed.
* You have the credentials that were generated in the previous step.

**Steps**:
1. Type `$ aws configure --profile <profile-name>` (replace `<profile-name>` with your profile name).
    * It's useful to use a `--profile` if you need to have more than one set of AWS credentials on the same machine.
    * Leaving out the `--profile <profile-name>` will set you up to use the `default` profile.
2. Input the requested information:

```bash
AWS Access Key ID [None]: <Access key ID>        
AWS Secret Access Key [None]: <Secret access key>
Default region name [None]: <Your region, e.g. eu-west-1>
Default output format [None]: text
``` 

This will store the credentials in `~/.aws/credentials`.
