# CloudFront & S3 Static Assets Setup

This guide details the deployment of the CloudFront CDN and S3 bucket for serving static assets.

## Architecture

- **Origin**: S3 Bucket (Private, Versioning Enabled)
- **Access Control**: OAC (Origin Access Control) restricts S3 access to CloudFront only.
- **Distribution**:
  - Protocol: HTTPS only (Redirects HTTP).
  - Caching Policy: `CachingOptimized` (Automatic compression).
  - Price Class: 100 (US/Canada/Europe) for cost optimization.

## Deployment

1. **Deploy Terraform**:
   Navigate to `terraform/environments/dev` and apply:

   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

   Confirm with `yes`.

2. **Retrieve Outputs**:
   Note the following outputs:
   - `cloudfront_domain_name`: The CDN URL (e.g., `d1234abcd.cloudfront.net`)
   - `s3_static_assets_bucket`: The name of the S3 bucket.

## Usage Guide

### 1. Upload Assets

Upload your static files (CSS, JS, Images) to the S3 bucket.

```bash
# Upload a file
aws s3 cp ./style.css s3://<s3_static_assets_bucket>/style.css

# Sync a directory
aws s3 sync ./assets/ s3://<s3_static_assets_bucket>/assets/
```

### 2. Update Application Code

Modify your application templates or configuration to point to the CloudFront domain instead of local paths or S3 URLs.

**HTML Example**:

```html
<!-- Old -->
<link rel="stylesheet" href="/static/style.css" />

<!-- New -->
<link rel="stylesheet" href="https://<cloudfront_domain_name>/style.css" />
```

### 3. Invalidation (After Updates)

Since CloudFront caches content, if you update a file in S3 with the same name, you must invalidate the cache to see changes immediately.

```bash
aws cloudfront create-invalidation \
    --distribution-id <DISTRIBUTION_ID> \
    --paths "/*"
```

_Note: Frequent invalidations cost money. For better cache management, use versioned filenames (e.g., `style.v1.css`) or cache busting query strings._

## Testing

1. Upload `index.html` to the bucket.
2. Visit `https://<cloudfront_domain_name>/index.html` in your browser.
3. Verify it redirects to HTTPS and loads the content.
4. Check Response Headers: `x-cache: Hit from cloudfront` (on second request).
