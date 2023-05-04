# Terraform Launch Script

Author:<br/>
> - Renan Monteiro Barbosa

Requirements:<br/>
> - AWS account
> - AWS CLI
> - Terraform CLI
> - Chocolatey

Commands:<br/>
- For Installing run:<br/>
> terraform init<br/>
> terraform plan<br/>
> terraform apply<br/>
- For Deleting run:<br/>
> terraform destroy<br/>

Expected behaviour:<br/>
The script should create a simple instance on AWS and will run the inscript(isaac-sim-oige.sh) to install an Isaac-Sim Docker container with OIGE and Robots converted to openUSD and ready to run on OIGE.<br/>

## Setup AWS (Good practices)
A good safety practice is never to use the Root account on AWS. Therefore, it is reccomended to create a user with admin permissions.<br/>
There are several ways to create an user, the most convenient way is to make a user with SSO access.<br/>

**Login to the Dashboard as Root user:**<br/>
- Go to IAM
- Create a User Group
- Create a User

Then go to **AWS IAM Identity Center-(AWS SSO):**<br/>
- Create a User
- Create a Group
- Add AWS account to the user in the group
- Create and Apply a Permission set
- Go to Settings —> Authentication
- Create MFA ( Multi Factor Authentication )

Now we can log on the AWS access portal URL:<br/>
Example: https://--subdomain name--.awsapps.com/start<br/>
You can create a custom subdomain name.<br/>
Now we can setup the AWS CLI with SSO<br/>


### **Configure AWS CLI**
Run code:<br/>
> aws configure --profile= >profile-name< <br/>

Should input on the terminal<br/>

> AWS Access Key ID [None]: >enter access key id<
> AWS Secret Access Key [None]: >enter secret access key<
> Default region name [None]: >AWS region<
> Default output format [None]: json

## Setup Terraform (Good practices)

## Github Repositories used
Note: The official Nvidia repo of OIGE dont work out of the box.<br/>

[OIGE-Omniverse Isaac Gym Reinforcement Learning Environments for Isaac Sim](https://github.com/boredengineering/OmniIsaacGymEnvs.git)

[Robots_for_Omniverse](https://github.com/boredengineering/Robots_for_Omniverse)

## Reference documentation
Source of documents<br/>

[Omniverse Isaac Sim on Amazon Web Services](https://docs.omniverse.nvidia.com/app_isaacsim/app_isaacsim/install_advanced_cloud_setup_aws.html)<br/>

[NVIDIA Omniverse GPU-Optimized AMI](https://aws.amazon.com/marketplace/pp/prodview-4gyborfkw4qjs?sr=0-1&ref_=beagle&applicationId=AWSMPContessa)

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

[Chocolatey](https://chocolatey.org/)

