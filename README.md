# ec2-deployment
This repo houses scripts necessary for the bootstrapping of new EC2 instances.
The flow of the provisioning processing in this case is: terraform launches the instance -> ec2 user data runs -> **ec2 deployment scripts called** -> ansible config runs

## ssh-key-injector.py
Using the boto3 library, this python script securely copies the root ssh private key from AWS Secrets Manager, formats it, and writes it to disk.

## jc-api-key-injector.py
Using the boto3 library, this python script securely copies the JumpCloud API key from AWS Secrets Manager, formats it, and writes it to disk.

## jc-system-key-injector.py
This python script opens up the JumpCloud .conf file to extract the unique system ID that is assigned during agent installation for use in ```bash-provision.sh```.

## bash-provision.sh
After the first two python scripts are run, bash-provision.sh is called by ec2 user data. This bash script performs a whole slew of tasks including: sets environment variables based on AWS region and instance ID, customizes the shell, adds the ssh fingerprint for bitbucket to known hosts, installs ansible, pulls and applies a base ansible config (sets hostname, timezone, and DNS), installs the JumpCloud agent (for systems management), grabs the unique system ID using ```jc-system-key-injector.py```, and finally adds the new instance to a group within JumpCloud that handles user account provisioning.