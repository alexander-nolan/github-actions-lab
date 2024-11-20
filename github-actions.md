# GitHub Actions Lab: Building a Terraform AWS Pipeline

## Overview
In this lab, you'll build a GitHub Actions pipeline for Terraform deployments to AWS, learning each component step by step. Instead of copying a complete pipeline, you'll construct it piece by piece, understanding each element.

## Prerequisites
- GitHub account
- AWS account with access credentials
- Basic Terraform knowledge
- A repository with some Terraform AWS code

## Lab Steps

### 1. Setting Up GitHub Secrets (10 mins)
Learn how to securely store credentials:
1. Navigate to your repository settings
2. Find "Secrets and variables" > "Actions"
3. Add the following secrets:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_REGION

**Challenge**: Add a test secret and then delete it to understand the secrets management interface.

### 2. Understanding Workflow Triggers (15 mins)
Explore different ways to trigger your pipeline:

1. Create `.github/workflows/terraform.yml`
2. Start with a basic trigger configuration:
```yaml
name: 'Terraform Pipeline'
on:
  push:
    branches: [ "main" ]
```

**Exercise**: 
- Add a pull_request trigger
- Add a manual trigger (workflow_dispatch)
- Add a schedule trigger for daily runs
- Test each trigger type

### 3. Environment Variables (15 mins)
Learn about different types of variables:

1. Add environment-wide variables
2. Add job-level variables
3. Use GitHub secrets

**Exercise**: 
- Set up a TF_LOG variable
- Create a variable that uses a secret
- Create an environment-specific variable

### 4. Building the Plan Stage (30 mins)
Create the Terraform plan job step by step:

1. Start with a basic job structure
2. Add AWS credential configuration
3. Add Terraform setup
4. Implement the plan step

**Guided Exercise**:
- Create the job structure (provide hints, not complete code)
- Add necessary steps one by one
- Test the plan output
- Learn to handle plan exit codes

### 5. Implementing Manual Approvals (20 mins)
Set up environment protection rules:

1. Create a protected environment
2. Configure approval requirements
3. Add environment to your workflow

**Challenge**:
- Set up a 'production' environment
- Add multiple approvers
- Configure branch restrictions

### 6. Creating the Apply Stage (30 mins)
Build the apply stage with artifact handling:

1. Create a new job dependent on plan
2. Add artifact download
3. Implement the apply step

**Exercise**:
- Handle job dependencies
- Manage plan artifacts
- Implement error handling

## Best Practices
- Always use secrets for credentials
- Implement proper error handling
- Use consistent naming conventions
- Include proper logging

## Resources
- GitHub Actions documentation
- Terraform documentation
- AWS authentication guides
- Example repositories (provide links)