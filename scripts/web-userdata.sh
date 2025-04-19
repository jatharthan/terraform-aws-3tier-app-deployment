#!/bin/bash

yum update -y
yum install -y mysql

sleep 10

# Run commands as ec2-user
su - ec2-user <<'EOF'

sleep 10

# Install NVM and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

sleep 10

# Set NVM_DIR explicitly to /home/ec2-user/.nvm and source nvm.sh
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

sleep 10

# Install Node.js 16
nvm install 16

sleep 10

# Use Node.js 16
nvm use 16

sleep 10

# Fetch app files from S3
cd ~/
aws s3 cp s3://ncpl-terraform-project9-jatha/web-tier/ web-tier --recursive

sleep 10

# Install app dependencies
cd ~/web-tier
npm install

sleep 10

#Build the application
npm run build

sleep 10

#Install NGINX
sudo amazon-linux-extras install nginx1 -y

sleep 10

#updating the file with details of internal loadbalancer
cd /etc/nginx
sudo rm nginx.conf
sudo aws s3 cp s3://ncpl-terraform-project9-jatha/nginx.conf .

sleep 10

#reatring nginx
sudo service nginx restart

sleep 10
#Giving nginx permissions to execute
chmod -R 755 /home/ec2-user

#start at boot
sudo chkconfig nginx on
sleep 10

EOF