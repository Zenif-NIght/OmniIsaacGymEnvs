# **Terraform Guide**

**Original Author:**<br/>
> - Renan Monteiro Barbosa

!!! Please, feel free to collaborate !!!<br/>

**Requirements:**<br/>
> - AWS account with Access to GPU instances
> - AWS CLI
> - Terraform CLI
> - OIGE repo

**Expected behaviour:**<br/>
The Terraform script should create a private key on the terraform folder named isaac-sim-oige-private-key.pem and an AWS instance and attach a public Key Pair to it. It will use the [NVIDIA Omniverse GPU-Optimized AMI](https://aws.amazon.com/marketplace/pp/prodview-4gyborfkw4qjs?sr=0-1&ref_=beagle&applicationId=AWSMPContessa) and will run the script (**isaac-sim-oige.sh**) to install an Isaac-Sim Docker Container with [OIGE](https://github.com/boredengineering/OmniIsaacGymEnvs.git) and [Robots_for_Omniverse](https://github.com/boredengineering/Robots_for_Omniverse) that contain robots ready to run on OIGE. <br/>

Verify the github repo [Robots_for_Omniverse](https://github.com/boredengineering/Robots_for_Omniverse) for the list of robots.  <br/>

## **Commands:**<br/>
Create an AWS Key pair. (either .pem (for terminal) or .ppk (for putty))<br/>
!!! Required to SSH into the instance. !!!<br/>

**Clone the OIGE Github repo**<br/>
> git clone https://github.com/boredengineering/OmniIsaacGymEnvs.git<br/>

Then go to the folder OmniIsaacGymEnvs/terraform<br/>
> cd OmniIsaacGymEnvs/terraform<br/>

**Terraform Commands:**<br/>
- For Installing run:<br/>
> terraform init<br/>
> terraform plan<br/>
> terraform apply<br/>
- For Deleting run:<br/>
> terraform destroy<br/>

**AWS CLI Commands:**<br/>
- Verify AWS CLI works.<br/>
> aws sso login --profile my-dev-profile <br/>

- If you cannot login, you probably have to configure your sso profile.<br/>
> aws configure sso

Should input on the terminal<br/>

> SSO start URL [None]: https://my-sso-portal.awsapps.com/start<br/>
> SSO region [None]: us-east-1<br/>
> CLI default client Region [None]: us-east-1<br/>
> CLI default output format [None]: json<br/>
> CLI profile name [some-profile-name]: profile-name<br/>

Verify created instance name 
- Describe Instances on a Region, if you need an specific region add: **--region name-of-region**<br/>
> aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Address:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --profile profile-name <br/>

- For accessing the Instance <br/>
> ssh stuff here

**Docker Commands:**<br/>
- Start or Stop the Docker Container<br/>
> docker start isaac-sim-oige<br/>
> docker stop isaac-sim-oige<br/>

- Verify running containers<br/>
> docker ps<br/>
- Verify all containers<br/>
> docker ps -a<br/>

- For connecting to the running Docker Container<br/>
> docker exec -it -w /workspace/omniisaacgymenvs/omniisaacgymenvs isaac-sim-oige bash<br/>



## **Setup AWS (Good practices)**
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

> aws configure sso

Should input on the terminal<br/>

> SSO session name (Recommended): my-sso<br/>
> SSO start URL [None]: https://my-sso-portal.awsapps.com/start<br/>
> SSO region [None]: us-east-1<br/>
> SSO registration scopes [None]: sso:account:access<br/>

For a default profile:<br/>
> aws configure --profile= >profile-name< <br/>

Should input on the terminal<br/>

> AWS Access Key ID [None]: >enter access key id<
> AWS Secret Access Key [None]: >enter secret access key<
> Default region name [None]: >AWS region<
> Default output format [None]: json

## **Setup Terraform (Good practices)**
**On windows, using Chocolatey**<br/>
> choco install terraform

Verify the installation<br/>
> terraform -help

**On Windows, manual install**<br/>
To install Terraform, find the (appropriate package)[https://developer.hashicorp.com/terraform/downloads] for your system and download it as a zip archive.<br/>
After downloading Terraform, unzip the package. Terraform runs as a single binary named **terraform**. Any other files in the package can be safely removed and Terraform will still function.<br/>
Finally, make sure that the **terraform** binary is available on your **PATH**. This process will differ depending on your operating system.<br/>

[This Stack Overflow article contains instructions for setting the PATH on Windows through the user interface.](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)

## **Github Repositories Used**
Note: The official Nvidia repo of OIGE dont work out of the box.<br/>

[OIGE-Omniverse Isaac Gym Reinforcement Learning Environments for Isaac Sim](https://github.com/boredengineering/OmniIsaacGymEnvs.git)

[Robots_for_Omniverse](https://github.com/boredengineering/Robots_for_Omniverse)

## **Reference Documentation**
Documentation Sources<br/>

[Omniverse Isaac Sim on Amazon Web Services](https://docs.omniverse.nvidia.com/app_isaacsim/app_isaacsim/install_advanced_cloud_setup_aws.html)<br/>

[NVIDIA Omniverse GPU-Optimized AMI](https://aws.amazon.com/marketplace/pp/prodview-4gyborfkw4qjs?sr=0-1&ref_=beagle&applicationId=AWSMPContessa)

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

[Chocolatey](https://chocolatey.org/)

[Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

[AWS CLI - Using an IAM Identity Center named profile](https://docs.aws.amazon.com/cli/latest/userguide/sso-using-profile.html)

[Token provider configuration with automatic authentication refresh for AWS IAM Identity Center (successor to AWS Single Sign-On)](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)

## **Useful Resources**

[Vantage.sh - aws instances](https://instances.vantage.sh/)<br/>
Vantage is a self-service cloud cost platform that gives developers the tools they need to analyze, report on and optimize AWS, Azure, and GCP costs.<br/>

To filter instances of the specified type and only display their instance IDs, Availability Zone and the specified tag value in table format<br/>
> aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Address:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --profile profile-name <br/>

Get public ip of an instance<br/>
> aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' -output text --profile profile-name <br/>

Note: can only get the Ip of running instances.