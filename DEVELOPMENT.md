# Local Development Setup

This file explains how to set up your local development environment for working on Sheldon's fitness website.

## Quick Start

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd Sheldon\'s\ Website

# 2. Configure AWS CLI with IAM user credentials
aws configure
# Enter Access Key ID, Secret Access Key, region (us-west-2), output format (json)

# 3. Test Terraform
cd terraform
terraform init
terraform plan

# 4. Verify website content
cd ..
python3 -m http.server 8000
# Visit http://localhost:8000 in your browser
```

## AWS Credentials

### Using AWS CLI Config (Recommended)

Your credentials are stored in `~/.aws/credentials` after running `aws configure`. This is the standard AWS approach and works automatically with Terraform.

```bash
aws configure
# Enter:
# AWS Access Key ID: AKIA...
# AWS Secret Access Key: [your secret]
# Default region: us-west-2
# Default output format: json
```

No additional setup needed—Terraform will read from `~/.aws/credentials` automatically.

### Creating an IAM User

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Click **Users** → **Create user**
3. Name: `sheldon-dev` or similar
4. Click **Create**
5. Go to the user → **Security credentials** → **Create access key**
6. Select **Command Line Interface (CLI)**
7. Copy the Access Key ID and Secret Access Key
8. Run `aws configure` and paste them in

### Required IAM Permissions

The IAM user needs these policies:

- `AmazonS3FullAccess`
- `CloudFrontFullAccess`
- `AWSCertificateManagerFullAccess`
- `AmazonRoute53FullAccess`

**Best practice:** Create a custom policy with only the minimum permissions needed, or use an IAM role with a trust policy instead.

## Local Website Testing

Preview the website locally without deploying:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000` in your browser. Changes to files in `public/` will be reflected on refresh.

## Terraform Workflow

### Planning Changes

```bash
cd terraform
terraform plan
```

Review the plan carefully. It shows:
- Resources to be created (`+`)
- Resources to be modified (`~`)
- Resources to be destroyed (`-`)

### Applying Changes

```bash
cd terraform
terraform apply
```

This will ask for confirmation. Type `yes` to proceed.

### Viewing State

```bash
terraform state list        # List all resources
terraform state show aws_s3_bucket.website  # Show details of a resource
```

**Warning:** Never edit `terraform.tfstate` directly.

## Git Workflow

### Before Pushing

1. Verify Terraform state files are not staged:
   ```bash
   git status | grep .tfstate
   # Should show nothing
   ```

2. Test your changes locally:
   ```bash
   python3 -m http.server 8000
   ```

### Committing Code

```bash
# Stage only website files
git add public/

# Or stage everything except secrets
git add .
git commit -m "Update homepage content"
git push origin main
```

### Triggering Terraform Apply via GitHub

To apply Terraform changes via GitHub Actions:

```bash
git commit -m "[terraform] update cloudfront caching rules"
git push origin main
```

The `[terraform]` tag triggers the Terraform apply job (requires approval in GitHub).

## Troubleshooting

### "AccessDenied" Error

Your AWS credentials are missing or invalid. Verify they are configured:

```bash
aws sts get-caller-identity
# Should output your AWS account ID and IAM user ARN
```

If this fails, run `aws configure` again and enter your Access Key ID and Secret Access Key.

### Terraform State Lock

If you see a "resource is locked" error, check for other developers applying changes. Wait a few minutes or contact them.

### Website Files Not Updating on S3

After syncing, invalidate the CloudFront cache:

```bash
cd terraform
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

CloudFront may take 5–10 minutes to refresh.

## GitHub Actions Secrets Setup

To enable automated deployments:

1. Go to your GitHub repo
2. **Settings** → **Secrets and variables** → **Actions**
3. Add:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

The `.github/workflows/deploy.yml` workflow will then automatically deploy on every push to `main`.

## Common Commands

```bash
# Preview site locally
python3 -m http.server 8000

# Plan Terraform changes
cd terraform && terraform plan

# Apply Terraform changes
cd terraform && terraform apply

# Sync website to S3
aws s3 sync public/ s3://$(cd terraform && terraform output -raw s3_bucket_name)/ --delete

# Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# View Terraform outputs
cd terraform && terraform output
```

## Questions?

Refer to:
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
