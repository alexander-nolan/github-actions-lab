# GitHub Actions Lab: Solution Guide

### Part 1: Initial Setup and Configuration

#### Fork the Repository
- Go to the repository page
- Click the "Fork" button in the top right
- Select your account as the destination

#### Generate AWS Access Keys
- Log into AWS Console
- Go to IAM → Users → Your User
- Click "Security credentials" tab
- Click "Create access key"
- Save both the Access Key ID and Secret Access Key

### Part 2: GitHub and AWS Configuration

#### Add GitHub Repository Secrets
- Go to your forked repository's Settings
- Click "Secrets and variables" → "Actions"
- Click "New repository secret"
- Add two secrets:
  ```
  Name: AWS_ACCESS_KEY_ID
  Value: (your access key from step 3)

  Name: AWS_SECRET_ACCESS_KEY
  Value: (your secret key from step 3)
  ```

#### Create GitHub Environment
- Go to repository Settings → Environments
- Click "New environment"
- Name it: gh-actions-lab
- Enable "Required reviewers"
- Add your GitHub username as a required reviewer
- Save protection rules

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

### Part 4: Repository Configuration

#### Clone and Create Feature Branch
- Clone your forked repository:
  ```bash
  git clone https://github.com/YOUR-USERNAME/REPO-NAME.git
  cd REPO-NAME
  ```
- Create and checkout a new feature branch:
  ```bash
  git checkout -b feature/github-actions-lab
  ```

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
#### Commit and Push Changes
- Stage and commit your changes:
  ```bash
  git add main/backend.tf
  git commit -m "Update S3 backend configuration"
  ```
- Push your feature branch to GitHub:
  ```bash
  git push -u origin feature/github-actions-lab
  ```
- Go to the Actions tab in GitHub
- Notice that no workflow is running yet - this is because there is no trigger configured for this branch.

#### Configure Pipeline Trigger
- Open `.github/workflows/terraform-plan-apply.yml`
- Add feature branch trigger to the `on` section:
  ```yaml
  on:
    push:
      branches: [ "feature/**" ]
    workflow_dispatch:
  ```
- Commit and push the changes:
  ```bash
  git add .github/workflows/terraform-plan-apply.yml
  git commit -m "Add feature branch trigger to workflow"
  git push
  ```

### Part 5: Deployment and Verification

#### Deploy Infrastructure
- Navigate to the Actions tab in GitHub
- You should now see the workflow running for your feature branch
- Watch the pipeline run through the plan stage
- When prompted, review the plan
- Click "Review deployments"
- Click "Approve and deploy"

#### Verify Deployment
- Wait for the terraform apply job to complete
- Copy the public IP from the terraform apply output
- Open the IP in your web browser
- You should see: "Welcome to the GitHub Actions & Terraform Lab!!"

### Part 6: Update AWS Region

#### Modify Pipeline Configuration
- Open `.github/workflows/terraform-plan-apply.yml`
- Locate the `env` section at the top of the file
- Change the AWS region to `us-west-2`:
  ```yaml
  env:
    TERRAFORM_DIR: './main'
    AWS_REGION: 'us-west-2'
  ```
- Commit and push your changes:
  ```bash
  git add .github/workflows/terraform-plan-apply.yml
  git commit -m "Update AWS region to us-west-2"
  git push
  ```

#### Verify Region Change
- Go to the Actions tab in GitHub
- Watch the new workflow run
- Review the plan carefully - you should see:
  - Resources being destroyed in us-east-1
  - Same resources being created in us-west-2
- Approve the deployment
- After successful deployment:
  - Verify the application works by accessing the new IP address
  - Confirm in the AWS Console that the resources are now in us-west-2

### Troubleshooting Guide

#### Common Issues and Solutions

##### Bucket Creation Issues
- "Bucket already exists" error:
  - Add a unique suffix to the bucket name (e.g., my-terraform-state-bucket-username)

##### Approval Issues
- Approval step not appearing:
  - Verify environment name is exactly "gh-actions-lab"
  - Check that you added yourself as a required reviewer

