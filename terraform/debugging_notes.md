

AWS CLI experimentation<br/>

```export AWS_PROFILE=my-aws-sso-profile```<br/>

```$Env:AWS_PROFILE = "my-aws-sso-profile"```<br/>

```aws ec2 describe-images --owners aws-marketplace --filters '[{"Name": "name", "Values": ["NVIDIA Omniverse GPU-Optimized AMI"]}, {"Name": "virtualization-type", "Values": ["hvm"]}, {"Name": "root-device-type", "Values": ["ebs"]}]' --query 'sort_by(Images, &CreationDate)[-1]' --region us-east-1 --output json```<br/>

```aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=NVIDIA Omniverse GPU-Optimized AMI" --query 'Images[*].[ImageId]' --region us-east-1 --output json```<br/>

```aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=NVIDIA Omniverse GPU-Optimized AMI" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query 'Images[*].[ImageId]' --region us-east-1 --output json```<br/>


Error with the .pem private key file<br/>
Note:<br/>
- The error only happens when trying to connect with Powershell or terminal on Windows<br/>
- Using Putty with a .ppk file works fine<br/>

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<br/>
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @<br/>
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<br/>
Permissions for 'isaac-sim-oige-private-key.pem' are too open.<br/>
It is required that your private key files are NOT accessible by others.<br/>
This private key will be ignored.<br/>
Load key "isaac-sim-oige-private-key.pem": bad permissions<br/>
root@54.144.212.33: Permission denied (publickey).<br/>

As per security policy, the private key file must not be publicly viewable in order to successfully log in to the server using SSH protocol.<br/>

Solutions<br/>
Solution 1:<br/>
On Linux:<br/>
chmod 400 server.pem <br/>

for windows users use:<br/>
> ```icacls.exe isaac-sim-oige-private-key.pem /reset```<br/>
> ```icacls.exe isaac-sim-oige-private-key.pem /grant:r "$($env:username):(r)"```<br/>
> ```icacls.exe isaac-sim-oige-private-key.pem /inheritance:r```<br/>

thats it! your keys.pem have same restrisctions as you use chmod 400<br/>
Note on Solution 1 - It doesn work<br/>

Solution 2:<br/>
Convert the .pem file to .ppk and use Putty<br/>

Solution 3:<br/>

```
resource "aws_key_pair" "generated_key" {

  # Name of key : Write the custom name of your key
  key_name   = "aws_keys_pairs"

  # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh

  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws_keys_pairs.pem
      chmod 400 aws_keys_pairs.pem
    EOT
  }
}
```

Use WinSCP from https://winscp.net/eng/index.php to convert the file<br/>

```winscp.com /keygen mykey.pem /output=mykey.ppk```<br/>