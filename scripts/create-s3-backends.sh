#!/bin/bash

# Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bucket-name> <region>"
    exit 1
fi

BUCKET_NAME=$1
REGION=$2

echo "Creating bucket: $BUCKET_NAME in region: $REGION..."

# 1. Create the bucket
if [ "$REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

# 2. Enable Versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --region "$REGION"

echo "Bucket '$BUCKET_NAME' is ready."