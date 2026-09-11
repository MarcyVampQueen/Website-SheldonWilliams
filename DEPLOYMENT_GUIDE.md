# Deployment Guide

This guide walks you through deploying Sheldon's website to AWS using Terraform.

## Prerequisites

1. **AWS Account:** Create one at [aws.amazon.com](https://aws.amazon.com) if you don't have one. The free tier covers the costs for this site.
2. **AWS CLI:** Install from [aws.amazon.com/cli](https://aws.amazon.com/cli)
3. **Terraform:** Install from [terraform.io](https://www.terraform.io/downloads)
4. **Domain Name:** Sheldon's chosen domain (e.g., `sheldon-fitness.com`). Preferably purchased and ready, or you can buy it from Route 53 after deploying the infrastructure.

## Step 1: Configure GitHub Actions with an OIDC Role

For GitHub Actions, the better approach is to create an IAM role that GitHub can assume using OpenID Connect (OIDC). This avoids storing long-lived AWS access keys in GitHub secrets.

### Local AWS CLI (optional)

If you want to run `aws s3 sync` or `terraform` locally on your machine, you can still use the AWS CLI with either:
- an IAM user with programmatic access, or
- AWS SSO / a profile configured locally

That is separate from GitHub Actions.



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
aws_account_id    = "179174776097"
aws_region        = "us-west-2"  # S3 and primary resources. ACM certificate always in us-east-1.
project_name      = "sheldon-fitness"
environment       = "prod"
```

## Step 3: Initialize Terraform

Initialize Terraform:

```bash
cd terraform
terraform init
```

Terraform will automatically use credentials from `aws configure`.

## Note on Regions

- **S3 bucket and most resources** are deployed to `us-west-2` (Oregon)
- **ACM SSL certificate** must be in `us-east-1` (AWS requirement for CloudFront)
  - Terraform uses a provider alias (`aws.us_east_1`) to handle this automatically
  - This does not affect performance; CloudFront serves from edge locations globally
- **Route 53** is global; DNS records work from any region

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

The workflow file `.github/workflows/deploy.yml` is already included in the project. It automatically:

1. **Syncs `public/` files to S3** on every push to `main` branch
2. **Invalidates CloudFront cache** automatically
3. **Optionally applies Terraform changes** via manual dispatch (workflow_dispatch)

### Setting Up GitHub Secrets

1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add this secret:
   - `AWS_ROLE_ARN` — The ARN of the IAM role created for GitHub OIDC

No AWS access key or secret key is required in GitHub anymore.

### Workflow Triggers

**Website deployment (automatic):**
- Push to `main` branch with changes to `public/` directory
- Website files sync to S3 and CloudFront cache invalidates automatically

> This repo is currently using the `master` branch, so if you are deploying from `master`, make sure the OIDC trust policy includes `refs/heads/master` as well.

**Terraform deployment (manual):**
1. Go to your GitHub repo → **Actions** tab
2. Click **Deploy to AWS** workflow
3. Click **Run workflow** button
4. Check **Apply Terraform changes?** toggle
5. Click **Run workflow**

The Terraform job will run `terraform plan`, show the changes, then apply them.

### Manual Website Deployment (without GitHub)

If you prefer not to use GitHub Actions:

```bash
aws configure  # If you haven't already

aws s3 sync public/ s3://sheldon-fitness-XXXXXXXXXX/ --delete
aws cloudfront create-invalidation --distribution-id XXXXXXXXXX --paths "/*"
```

### GitHub Actions Environment

The workflow uses a `production` environment. You can optionally require approval before deployments:

1. Go to **Settings** → **Environments**
2. Create an environment named `production`
3. Enable **Required reviewers** to require approval before deployments

Removing the `environment: production` line from the workflow disables this.

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
