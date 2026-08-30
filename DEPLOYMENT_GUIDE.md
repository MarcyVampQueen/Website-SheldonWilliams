# Deployment Guide

This guide walks you through deploying Sheldon's website to AWS using Terraform.

## Prerequisites

1. **AWS Account:** Create one at [aws.amazon.com](https://aws.amazon.com) if you don't have one. The free tier covers the costs for this site.
2. **AWS CLI:** Install from [aws.amazon.com/cli](https://aws.amazon.com/cli)
3. **Terraform:** Install from [terraform.io](https://www.terraform.io/downloads)
4. **Domain Name:** Sheldon's chosen domain (e.g., `sheldon-fitness.com`). Preferably purchased and ready, or you can buy it from Route 53 after deploying the infrastructure.

## Step 1: Configure AWS Credentials

```bash
# Create an IAM user with programmatic access (Access Key ID + Secret Access Key)
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

aws configure
# Enter your Access Key ID when prompted
# Enter your Secret Access Key when prompted
# Default region: us-east-1 (required for CloudFront)
# Default output format: json (optional)
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Step 2: Prepare Terraform Variables

```bash
# Copy the example variables file
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with Sheldon's domain and your email
nano terraform/terraform.tfvars
```

Example `terraform.tfvars`:

```hcl
domain_name       = "sheldon-fitness.com"
certificate_email = "admin@sheldon-fitness.com"
aws_region        = "us-east-1"
project_name      = "sheldon-fitness"
environment       = "prod"
```

## Step 3: Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads the AWS provider and prepares the working directory.

## Step 4: Review the Deployment Plan

```bash
terraform plan
```

This shows you exactly what resources will be created without making any changes. Review the output carefully. You should see:

- S3 bucket for the website
- CloudFront distribution
- ACM certificate
- Route 53 hosted zone and DNS records
- IAM policies and access controls

## Step 5: Deploy to AWS

```bash
terraform apply
```

Terraform will ask for confirmation. Type `yes` and press Enter.

**This step will:**
1. Create the S3 bucket (encrypted, versioned, private)
2. Create the CloudFront distribution
3. Request an SSL certificate from AWS Certificate Manager
4. Create a Route 53 hosted zone for the domain
5. Set up DNS records to point the domain to CloudFront

**Estimated time:** 10–15 minutes (ACM certificate validation can take a few minutes)

## Step 6: Update Domain Registrar (if needed)

If Sheldon's domain was purchased elsewhere (GoDaddy, Namecheap, etc.), update the nameservers:

```bash
terraform output route53_nameservers
```

This outputs the Route 53 nameservers. Point Sheldon's domain registrar to these nameservers.

**If you bought the domain on Route 53:** This step is automatic; you can skip it.

## Step 7: Upload Website Content

```bash
aws s3 sync ../public/ s3://sheldon-fitness-XXXXXXXXXX/ --delete
```

Replace `sheldon-fitness-XXXXXXXXXX` with the actual bucket name from:

```bash
terraform output s3_bucket_name
```

## Step 8: Invalidate CloudFront Cache

```bash
aws cloudfront create-invalidation \
  --distribution-id $(terraform output cloudfront_distribution_id) \
  --paths "/*"
```

This tells CloudFront to refresh the cache immediately (otherwise it can take up to 24 hours).

## Step 9: Test the Website

```bash
terraform output website_url
```

Visit the URL in your browser. It should show the Sheldon Fitness site with HTTPS enabled.

**DNS propagation:** If the domain is redirecting, wait 5–30 minutes for DNS to propagate globally.

For immediate testing, use the CloudFront URL:

```bash
terraform output cloudfront_url_for_testing
```

## Updating Content Later

After the initial deployment, updating the website is simple:

```bash
# 1. Edit files in public/
nano public/index.html

# 2. Sync to S3
aws s3 sync public/ s3://sheldon-fitness-XXXXXXXXXX/ --delete

# 3. Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output cloudfront_distribution_id) \
  --paths "/*"
```

## Automating Deployments with GitHub Actions

To automate the upload and cache invalidation on every `git push`, create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to AWS

on:
  push:
    branches:
      - main
    paths:
      - 'public/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Sync to S3
        run: |
          aws s3 sync public/ s3://sheldon-fitness-XXXXXXXXXX/ --delete
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id XXXXXXXXXX \
            --paths "/*"
```

Then add your AWS credentials as GitHub secrets.

## Destroying the Infrastructure (if needed)

To delete all AWS resources (and be careful—this is not easily reversible):

```bash
cd terraform
terraform destroy
```

Type `yes` to confirm. AWS will delete the S3 bucket, CloudFront, certificates, and hosted zone.

## Troubleshooting

### Terraform Error: "AccessDenied"

Your AWS credentials don't have permission. Ensure the IAM user has these policies:
- `AmazonS3FullAccess`
- `CloudFrontFullAccess`
- `AWSCertificateManagerFullAccess`
- `AmazonRoute53FullAccess`
- `IAMReadOnlyAccess`

### ACM Certificate Not Validating

The certificate needs DNS validation. Route 53 records are created automatically, but may take a few minutes. Check the AWS Certificate Manager console to see the validation status.

### CloudFront Still Shows Old Content

Cache invalidation can take a few minutes. Wait, then refresh your browser and clear the cache (Cmd+Shift+R on macOS).

### Domain Not Resolving

If you updated the nameservers at the registrar, it can take 24–48 hours to propagate globally. Use a DNS checker like [whatsmydns.net](https://www.whatsmydns.net) to monitor propagation.

## Next Steps

- Integrate Calendly booking link into `public/index.html`
- Add PayPal payment buttons to the site
- Write the privacy notice and terms of service
- Set up email forwarding or contact method
- Consider adding a blog or additional pages

## Cost Estimate

| Service | Monthly Cost |
|---|---|
| S3 storage (100 MB) | ~$0.02 |
| S3 GET requests (10k/mo) | ~$0.04 |
| CloudFront data out (10 GB/mo) | ~$0.50 |
| CloudFront requests (10k/mo) | ~$0.01 |
| Route 53 hosted zone | $0.40 |
| **Total** | **~$1.00** |

After the first 12 months, AWS may offer reduced rates or extended free tier. The certificate is free.

## Questions?

Refer to the official documentation:
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
