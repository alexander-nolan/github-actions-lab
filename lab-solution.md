# GitHub Actions Lab: Solution Guide

### Part 1: Initial Setup and Configuration

#### Generate AWS Access Keys
- Log into AWS Console
- Go to IAM → Users → Your User
- Click "Security credentials" tab
- Click "Create access key"
- Save both the Access Key ID and Secret Access Key

#### Fork the Repository
- Go to the repository page
- Click the "Fork" button in the top right
- Select your account as the destination

### Part 2: GitHub and AWS Configuration

#### Create GitHub Environment
- Go to repository Settings → Environments
- Click "New environment"
- Name it: gh-actions-lab
- Enable "Required reviewers"
- Add your GitHub username as a required reviewer
- Save protection rules

#### Add GitHub Environment Secrets
- In repository Settings → Environments
- Click on "gh-actions-lab" environment
- Scroll down to "Environment secrets"
- Click "Add secret"
- Add two secrets:
  ```
  Name: AWS_ACCESS_KEY_ID
  Value: (your access key from step 3)

  Name: AWS_SECRET_ACCESS_KEY
  Value: (your secret key from step 3)
  ```

### Part 3: AWS Local Configuration

#### Configure AWS CLI
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

#### Create S3 Backend
- In your terminal, run:
  ```bash
  aws s3 mb s3://my-terraform-state-bucket --region us-east-1
  ```
- If this fails with "bucket already exists", add a unique suffix to the bucket name
- Remember the bucket name you used

#### Update Backend Configuration
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

### Part 4: Deployment and Verification

#### Deploy Infrastructure
- Commit and push your changes to main branch
- Go to Actions tab in GitHub
- Watch the pipeline run
- When prompted, review the plan
- Click "Review deployments"
- Click "Approve and deploy"

#### Verify Deployment
- Wait for apply job to complete
- Copy the public IP from the terraform apply output
- Open the IP in your web browser
- You should see: "Welcome to the GitHub Actions & Terraform Lab!!"

### Troubleshooting Guide

#### Common Issues and Solutions

##### Bucket Creation Issues
- "Bucket already exists" error:
  - Add a unique suffix to the bucket name (e.g., my-terraform-state-bucket-username)

##### Approval Issues
- Approval step not appearing:
  - Verify environment name is exactly "gh-actions-lab"
  - Check that you added yourself as a required reviewer

