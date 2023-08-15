#!/bin/bash

DOMAIN="fukuoka-developers.com"

# Route53 hosted zone
HOSTED_ZONE_ID=$(aws route53 create-hosted-zone \
  --name $DOMAIN \
  --caller-reference "$(date +%Y-%m-%d_%H-%M-%S)" \
  --query "HostedZone.Id" --output text) && echo $HOSTED_ZONE_ID

# ACM 
CERTIFICATE_ARN=$(aws acm request-certificate \
    --domain-name $DOMAIN \
    --validation-method DNS \
    --query "CertificateArn" --output text) && echo $CERTIFICATE_ARN

VALIDATION_RECORD_NAME=$(aws acm describe-certificate \
  --certificate-arn $CERTIFICATE_ARN \
  --query "Certificate.DomainValidationOptions[*].ResourceRecord.Name" --output text) && echo $VALIDATION_RECORD_NAME

VALIDATION_RECORD_VALUE=$(aws acm describe-certificate \
  --certificate-arn $CERTIFICATE_ARN \
  --query "Certificate.DomainValidationOptions[*].ResourceRecord.Value" --output text) && echo $VALIDATION_RECORD_VALUE

# Update record sets file
VALIDATION_RECORD_FILE=./recordsets/dnsvalidation.json
sed -i -e "s/%VALIDATION_RECORD_NAME%/$VALIDATION_RECORD_NAME/" $VALIDATION_RECORD_FILE
sed -i -e "s/%VALIDATION_RECORD_VALUE%/$VALIDATION_RECORD_VALUE/" $VALIDATION_RECORD_FILE

# Add record sets
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://$VALIDATION_RECORD_FILE

# Initialize（実行後に戻す）
#git restore $VALIDATION_RECORD_FILE