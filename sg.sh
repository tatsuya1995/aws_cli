#!/bin/bash

PREFIX="fukuoka"
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=${PREFIX}-vpc --query "Vpcs[*].VpcId" --output text) && echo $VPC_ID

# EC2
EC2_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name ${PREFIX}-ec2-sg \
    --description ${PREFIX}-ec2-sg \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-ec2-sg}]" \
    --query "GroupId" --output text) && echo $EC2_SECURITY_GROUP_ID

IP=$(curl -s https://api.ipify.org)
aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr ${IP}/32

aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# RDS
RDS_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name ${PREFIX}-rds-sg \
    --description ${PREFIX}-rds-sg \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-rds-sg}]" \
    --query "GroupId" --output text) && echo $RDS_SECURITY_GROUP_ID

aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 3306 \
    --source-group $EC2_SECURITY_GROUP_ID