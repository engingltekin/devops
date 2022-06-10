#! /bin/bash
yum update -y
hostnamectl set-hostname worker-node
yum upgrade
rm -rf /bin/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install