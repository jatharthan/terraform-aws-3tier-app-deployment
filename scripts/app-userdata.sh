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

# Install PM2
npm install -g pm2

sleep 10

# Fetch app files from S3
cd ~/
aws s3 cp s3://ncpl-terraform-project9-jatha/app-tier/ app-tier --recursive

sleep 10

# Install app dependencies
cd ~/app-tier
npm install

sleep 10

# Start the app with PM2
pm2 start index.js

sleep 10

# Save PM2 process list
pm2 save

sleep 10

# Configure PM2 to start on boot
pm2 startup systemd -u ec2-user --hp /home/ec2-user

sleep 10

EOF
