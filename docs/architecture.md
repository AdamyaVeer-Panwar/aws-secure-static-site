# Architecture

## Request path

1. A visitor requests the site over HTTPS.
2. Amazon CloudFront serves cached content from its edge locations.
3. On a cache miss, CloudFront signs the origin request with SigV4 using Origin Access Control (OAC).
4. The private S3 bucket policy permits `s3:GetObject` only to the CloudFront service principal when the request's `AWS:SourceArn` matches this distribution.
5. S3 Block Public Access remains enabled. Visitors do not receive direct S3 access.

## Components

| Component | Responsibility | Security / operations choice |
|---|---|---|
| Amazon S3 | Stores static HTML assets | Public access blocked, bucket-owner-enforced ownership, versioning, SSE-S3 encryption |
| CloudFront | HTTPS edge delivery and caching | S3 OAC, HTTPS redirect, compression, PriceClass_100 |
| Terraform | Reproducible infrastructure | Declarative configuration and tagged resources |
| GitHub Actions | Pull request / main branch validation | Read-only repository permission; no AWS credentials required for validation |

## Trust boundary

The public internet can reach CloudFront. The S3 bucket is not a public website endpoint. The bucket policy grants read access only to the configured CloudFront distribution. Terraform deployment itself requires an AWS principal with permissions to manage the resources in this project.

## Deliberate scope limits

This is a small portfolio project, not a full enterprise landing zone. It does not configure a custom domain, ACM certificate, WAF, DNS, centralized logging, multi-account governance, or a production deployment role. Add those only when the requirements justify the added cost and operational complexity.
