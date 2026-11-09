# Secure Static Website Delivery on AWS

A focused Cloud Engineering project that provisions a **private Amazon S3 origin** and serves static website assets through **Amazon CloudFront**. Infrastructure is managed with Terraform, and GitHub Actions runs formatting and validation checks.

> **Project status:** Source code and infrastructure configuration are prepared for review. The repository is not represented as live-deployed. After deploying it in an AWS account, replace this note with the verified CloudFront URL and deployment evidence.

## What this demonstrates

- Infrastructure as Code with Terraform.
- Secure S3 origin: Block Public Access, bucket-owner-enforced ownership, versioning, and server-side encryption.
- CloudFront Origin Access Control (OAC) with SigV4-signed origin requests.
- Least-exposure bucket policy scoped to the CloudFront distribution ARN.
- HTTPS-only viewer access (HTTP redirects to HTTPS).
- GitHub Actions CI for `terraform fmt` and `terraform validate`.
- Resource tagging and an explicit teardown path.

## Architecture

```text
Visitor
  |
  | HTTPS
  v
Amazon CloudFront
  |
  | SigV4 signed origin request (OAC)
  v
Private Amazon S3 bucket
  - Block Public Access
  - Versioning enabled
  - SSE-S3 encryption
```

See [`docs/architecture.md`](docs/architecture.md) for component responsibilities and trust boundaries.

## Repository layout

```text
.
├── .github/workflows/terraform-ci.yml
├── docs/architecture.md
├── infrastructure/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── versions.tf
└── website/
    ├── 404.html
    └── index.html
```

## Prerequisites

- Terraform CLI `>= 1.5.0`.
- AWS CLI v2.
- An AWS account.
- An AWS identity configured locally with permissions to create/manage the S3, CloudFront, and supporting resources used here.

Do not commit AWS access keys, secret keys, state files, or real `.tfvars` files.

## Deploy

Run these commands from the repository root in PowerShell or a Unix shell:

```bash
cd infrastructure
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Terraform creates the private bucket, CloudFront distribution, access policy, and uploads the two HTML files. CloudFront distribution deployment can take several minutes after `apply` completes.

Get the outputs:

```bash
terraform output website_url
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
```

Open the `website_url` output after CloudFront has finished deploying.

## Update website content

The initial HTML files are uploaded by Terraform. If you edit them after deployment, run `terraform apply` again so the object resources detect the changed file hashes:

```bash
terraform apply
```

CloudFront may continue serving cached content briefly. Create an invalidation when needed:

```bash
aws cloudfront create-invalidation --distribution-id "$(terraform output -raw cloudfront_distribution_id)" --paths "/*"
```

PowerShell equivalent:

```powershell
$distributionId = terraform output -raw cloudfront_distribution_id
aws cloudfront create-invalidation --distribution-id $distributionId --paths '/*'
```

## CI validation

The GitHub Actions workflow runs on pull requests and pushes to `main` when Terraform files change. It checks formatting, initializes providers without configuring a backend, and validates the Terraform configuration. This CI job does not deploy infrastructure and does not need AWS credentials.

## Cost and cleanup

CloudFront requests/data transfer and S3 storage/requests can incur charges. Check current pricing for the AWS region and expected traffic before deployment. Set an AWS Budget or billing alert first. Do not deploy into an account without authorization.

When finished, remove the demo resources:

```bash
cd infrastructure
terraform destroy
```

The demo bucket uses `force_destroy = true` so Terraform can remove the uploaded sample files. This is convenient for a disposable demo but should be reconsidered for buckets containing valuable data.

## Security notes

- S3 public access is blocked at the bucket level.
- The bucket policy grants `s3:GetObject` to CloudFront only and scopes it to this distribution's ARN.
- CloudFront uses OAC with SigV4 signing.
- No AWS credentials are stored in the repository or required by the CI validation workflow.
- The Terraform execution identity should be limited to the permissions required to manage these resources.

## Verification checklist

After a real deployment, verify and record:

- [ ] GitHub Actions Terraform CI passes.
- [ ] `terraform validate` succeeds locally.
- [ ] CloudFront URL returns the expected page over HTTPS.
- [ ] Direct anonymous access to the S3 object is denied.
- [ ] S3 Block Public Access settings are all enabled.
- [ ] `terraform destroy` removes the demo resources.

## Next improvements

1. Add a custom domain and ACM certificate in `us-east-1`.
2. Add AWS WAF managed rules and rate-based protection.
3. Add access logs and operational dashboards.
4. Add a dedicated GitHub Actions deployment role using GitHub OIDC with a narrowly scoped trust policy.
5. Add automated browser smoke tests after deployment.

## Author

**Adamya Panwar** — GitHub: [AdamyaVeer-Panwar](https://github.com/AdamyaVeer-Panwar)
