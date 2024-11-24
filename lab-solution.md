# GitHub Actions Lab: Solution Guide

## Step-by-Step Instructions

1. Fork the repository
   - Go to the repository page
   - Click the "Fork" button in the top right
   - Select your account as the destination

2. Verify GitHub Action
   - Go to the "Actions" tab in your forked repository
   - Confirm the workflow appears and has attempted to run

3. Generate AWS Access Keys
   - Log into AWS Console
   - Go to IAM → Users → Your User
   - Click "Security credentials" tab
   - Click "Create access key"
   - Save both the Access Key ID and Secret Access Key

4. Add GitHub Repository Secrets
   - Go to your forked repository's Settings
   - Click "Secrets and variables" → "Actions"
   - Click "New repository secret"
   - Add three secrets:
     ```
     Name: AWS_ACCESS_KEY_ID
     Value: (your access key from step 3)

     Name: AWS_SECRET_ACCESS_KEY
     Value: (your secret key from step 3)

     Name: AWS_REGION
     Value: us-east-1
     ```

5. Create GitHub Environment
   - Go to repository Settings → Environments
   - Click "New environment"
   - Name it: gh-actions-lab
   - Enable "Required reviewers"
   - Add your GitHub username as a required reviewer
   - Save protection rules

6. Configure AWS CLI Locally
   - Open ~/.aws/credentials in a text editor
   - Add the following section:
     ```
     [gh-actions-lab]
     aws_access_key_id = YOUR_ACCESS_KEY_ID
     aws_secret_access_key = YOUR_SECRET_KEY
     ```
   - In your terminal, run:
     ```bash
     export AWS_PROFILE=gh-actions-lab
     ```

7. Create S3 Backend Bucket
   - In your terminal, run:
     ```bash
     aws s3 mb s3://my-terraform-state-bucket --region us-east-1
     ```
   - If this fails with "bucket already exists", add a unique suffix to the bucket name
   - Remember the bucket name you used

8. Update Backend Configuration
   - Open main/backend.tf
   - Update the bucket name to match your created bucket:
     ```hcl
     terraform {
       backend "s3" {
         bucket = "your-actual-bucket-name"
         key    = "dev/terraform.tfstate"
         region = "us-east-1"
       }
     }
     ```

9. Deploy Infrastructure
   - Commit and push your changes to main branch
   - Go to Actions tab in GitHub
   - Watch the pipeline run
   - When prompted, review the plan
   - Click "Review deployments"
   - Click "Approve and deploy"

10. Verify Deployment
    - Wait for apply job to complete
    - Copy the public IP from the terraform apply output
    - Open the IP in your web browser
    - You should see: "Welcome to the GitHub Actions & Terraform Lab!!"

## Common Issues and Solutions

- "Bucket already exists" error:
  - Add a unique suffix to the bucket name (e.g., my-terraform-state-bucket-username)

- Pipeline fails with 403 error:
  - Verify AWS region is set to us-east-1 in all locations
  - Check that AWS credentials are correctly copied
  - Ensure bucket name in backend.tf matches exactly

- Approval step not appearing:
  - Verify environment name is exactly "gh-actions-lab"
  - Check that you added yourself as a required reviewer

