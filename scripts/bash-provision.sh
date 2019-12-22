#!/bin/bash

#variable declarations
git_repository="your-repo-url.git"
region=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
instanceid=$(curl http://169.254.169.254/latest/meta-data/instance-id)
#setup environment variables to be used by ansible
export AWS_REGION=$region
export AWS_INSTANCE_ID=$instanceid
echo "export AWS_REGION=$region" >> /etc/profile.d/iotas-env.sh
echo "export AWS_INSTANCE_ID=$instanceid" >> /etc/profile.d/iotas-env.sh
chmod +x /etc/profile.d/iotas-env.sh
#install screenfetch
apt install -y screenfetch
#add color prompts to new user accounts
echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '" >> /etc/skel/.bashrc
#add screenfetch to new user accounts
echo -e '\nscreenfetch\n\n' >> /etc/skel/.bashrc
#add bitbucket to known hosts
ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
#set permissions on private key and known hosts
chmod 0400 /root/.ssh/id_rsa /root/.ssh/known_hosts
#install ansible with pip
/usr/bin/pip install ansible
#pull and applies ansible config from bitbucket
ansible-pull provision.yml -C master -U $git_repository -fi localhost, --full --purge
#add universe repo for JumpCloud
add-apt-repository universe
#install the JumpCloud agent
curl --tlsv1.2 --silent --show-error --header 'x-connect-key: *your-x-connect-key*' https://kickstart.jumpcloud.com/Kickstart | sudo bash
#wait 30 seconds
sleep 30
#inject JumpCloud system key
/usr/bin/python3 /root/scripts/jc-system-key-injector.py
#wait 5 seconds
sleep 5
#add system to JumpCloud System Group "Servers - Ubuntu"
i="curl -X POST *URL-to-your-system-group-members-page* -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-api-key: $(cat /root/jc-api-key)' -d '{\"op\": \"add\",\"type\": \"system\",\"id\": \"$(cat /root/jc-system-key)\"}'"
eval "$i"