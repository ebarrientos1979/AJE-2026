#!/bin/bash

echo "🚀 Deploying AJE Delivery HTML App with CloudFront..."

# Create S3 and CloudFront infrastructure
echo "🏗️  Creating infrastructure (this may take 10-15 minutes for CloudFront)..."
terraform init
terraform apply -auto-approve

# Get bucket name
BUCKET_NAME=$(terraform output -raw bucket_name)
echo "📦 S3 Bucket: $BUCKET_NAME"

# Upload files to S3
echo "📤 Uploading files to S3..."
aws s3 cp index.html s3://$BUCKET_NAME/index.html --profile default
aws s3 cp app.js s3://$BUCKET_NAME/app.js --profile default
aws s3 cp config.json s3://$BUCKET_NAME/config.json --profile default

# Get CloudFront URL
WEBSITE_URL=$(terraform output -raw website_url)

echo ""
echo "✅ Deployment complete!"
echo "🌐 Website URL: $WEBSITE_URL"
echo ""
echo "⏳ CloudFront may take 5-10 minutes to fully propagate"
echo "🧪 Test the application:"
echo "curl -I $WEBSITE_URL"
