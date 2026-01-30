#!/bin/bash

echo "🚀 Deploying AJE Delivery HTML App to S3..."

# Create S3 infrastructure
echo "🏗️  Creating S3 infrastructure..."
terraform init
terraform apply -auto-approve

# Get bucket name
BUCKET_NAME=$(terraform output -raw bucket_name)
echo "📦 S3 Bucket: $BUCKET_NAME"

# Upload files to S3 (without ACL)
echo "📤 Uploading files to S3..."
aws s3 cp index.html s3://$BUCKET_NAME/index.html --profile default
aws s3 cp app.js s3://$BUCKET_NAME/app.js --profile default
aws s3 cp config.json s3://$BUCKET_NAME/config.json --profile default

# Get website URL
WEBSITE_URL=$(terraform output -raw website_url)

echo ""
echo "✅ Deployment complete!"
echo "🌐 Website URL: $WEBSITE_URL"
echo ""
echo "⚠️  Note: Files are private but accessible via website endpoint"
echo "🧪 Test the application:"
echo "curl -I $WEBSITE_URL"
