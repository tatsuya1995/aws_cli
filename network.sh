#!/bin/bash
## https://zenn.dev/amarelo_n24/articles/35cb14a057ecf1

# VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --instance-tenancy default \
    --tag-specifications "ResourceType=vpc, Tags=[{Key=Name, Value=fukuoka-01-vpc}]"

VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=fukuoka-01-vpc \
   --query "Vpcs[*].VpcId" --output text)

# IGW
INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications "ResourceType=internet-gateway, Tags=[{Key=Name, Value=fukuoka-igw}]" \
    --query "InternetGateway.InternetGatewayId" --output text)

aws ec2 attach-internet-gateway \
   --internet-gateway-id $INTERNET_GATEWAY_ID \
   --vpc-id $VPC_ID

# Public Subnet

# Private Subnet

# Root Table

