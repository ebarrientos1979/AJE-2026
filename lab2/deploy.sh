#!/bin/bash

# Deploy script for Lab 3
echo "🚀 Deploying Bedrock RAG API..."

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Planning deployment..."
terraform plan

# Apply deployment
echo "🔧 Applying deployment..."
terraform apply -auto-approve

# Get API URL
API_URL=$(terraform output -raw api_url)
echo ""
echo "✅ Deployment complete!"
echo "🌐 API URL: $API_URL"
echo ""
echo "🧪 Test the API:"
echo "python3 test_api.py"
echo ""
echo "📝 Manual test:"
echo "curl -X POST $API_URL \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"query\": \"¿Qué productos tienen disponibles?\"}'"
