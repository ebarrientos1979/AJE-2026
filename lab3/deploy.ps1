# PowerShell deployment script for Windows
Write-Host "🚀 Deploying AJE Delivery HTML App to S3..." -ForegroundColor Green

# Create S3 infrastructure
Write-Host "🏗️ Creating S3 infrastructure..." -ForegroundColor Yellow
terraform init
terraform apply -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create infrastructure" -ForegroundColor Red
    exit 1
}

# Get bucket name
$bucketName = terraform output -raw bucket_name
Write-Host "📦 S3 Bucket: $bucketName" -ForegroundColor Cyan

# Upload files to S3
Write-Host "📤 Uploading files to S3..." -ForegroundColor Yellow
aws s3 cp index.html s3://$bucketName/index.html --profile default
aws s3 cp app.js s3://$bucketName/app.js --profile default
aws s3 cp config.json s3://$bucketName/config.json --profile default

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to upload files" -ForegroundColor Red
    exit 1
}

# Get website URL
$websiteUrl = terraform output -raw website_url

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Website URL: $websiteUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "🧪 Test the application:" -ForegroundColor Yellow
Write-Host "Invoke-WebRequest -Uri $websiteUrl -Method Head" -ForegroundColor Gray
