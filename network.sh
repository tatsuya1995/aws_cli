#!/bin/bash

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
PUBLIC_SUBNET_ID_1A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.12.0/24 \
    --availability-zone ap-northeast-1a \
    --tag-specifications "ResourceType=subnet, Tags=[{Key=Name, Value=fukuoka-public-subnet-1a}]" \
    --query "Subnet.SubnetId" --output text)

# Root Table
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table, Tags=[{Key=Name, Value=fukuoka-public-route}]" \
    --query "RouteTable.RouteTableId" --output text)

# Root Table TO IGW
aws ec2 create-route \
    --route-table-id $ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $INTERNET_GATEWAY_ID

# Root Table TO Public Subnet
aws ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID \
    --subnet-id $PUBLIC_SUBNET_ID_1A