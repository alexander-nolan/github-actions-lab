# GitHub Actions Lab: Instructor Solution Guide
ase 
## Complete Pipeline Solution
This is the reference solution for instructors. Students should be encouraged to build their own pipeline following the lab guide.

```yaml
name: 'Terraform AWS Pipeline'

# Trigger configuration
on:
  push:
    branches: [ "main" ]
    paths:
      - 'terraform/**'
      - '.github/workflows/**'
  pull_request:
    branches: [ "main" ]
    paths:
      - 'terraform/**'
  workflow_dispatch:

# Permission configuration
permissions:
  contents: read
  pull-requests: write
  issues: write

# Environment variables
env:
  TF_LOG: INFO
  AWS_REGION: ${{ secrets.AWS_REGION }}
  TERRAFORM_DIR: './terraform'

jobs:
  terraform-plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest
    
    # Job outputs for use in other jobs
    outputs:
      tfplanExitCode: ${{ steps.tf-plan.outputs.exitcode }}

    steps:
    # Basic setup steps
    - name: Checkout Repository
      uses: actions/checkout@v3

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
        terraform_wrapper: false

    # Terraform steps
    - name: Terraform Format Check
      id: fmt
      run: terraform fmt -check -recursive
      working-directory: ${{ env.TERRAFORM_DIR }}
      continue-on-error: true

    - name: Terraform Init
      id: init
      run: terraform init
      working-directory: ${{ env.TERRAFORM_DIR }}

    - name: Terraform Validate
      id: validate
      run: terraform validate
      working-directory: ${{ env.TERRAFORM_DIR }}

    # Plan with detailed output handling
    - name: Terraform Plan
      id: tf-plan
      run: |
        terraform plan -detailed-exitcode -no-color -out=tfplan \
        || exit_code=$?
        echo "exitcode=${exit_code}" >> $GITHUB_OUTPUT
        
        if [ $exit_code -eq 1 ]; then
          echo "Terraform Plan Failed!"
          exit 1
        else 
          exit 0
        fi
      working-directory: ${{ env.TERRAFORM_DIR }}
      continue-on-error: true

    # Save plan output for PR comments
    - name: Save Plan Output
      if: github.event_name == 'pull_request'
      run: |
        terraform show -no-color tfplan > tfplan.txt
      working-directory: ${{ env.TERRAFORM_DIR }}

    # Upload plan artifact
    - name: Upload Terraform Plan
      uses: actions/upload-artifact@v3
      with:
        name: tfplan
        path: ${{ env.TERRAFORM_DIR }}/tfplan
        retention-days: 1

    # Add plan as PR comment
    - name: Add Plan to PR
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const fs = require('fs');
          const planOutput = fs.readFileSync('${{ env.TERRAFORM_DIR }}/tfplan.txt', 'utf8');
          const maxLength = 65536;
          
          const output = `#### Terraform Plan Output
          \`\`\`
          ${planOutput.length > maxLength ? planOutput.substring(0, maxLength) + '\n\n... Output truncated ...' : planOutput}
          \`\`\`
          `;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

  # Manual approval job
  approval:
    needs: terraform-plan
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main' && needs.terraform-plan.outputs.tfplanExitCode == '2'
    
    steps:
    - name: Approval Gate
      run: echo "Waiting for approval..."

  # Apply job
  terraform-apply:
    needs: [terraform-plan, approval]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && needs.terraform-plan.outputs.tfplanExitCode == '2'
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
        terraform_wrapper: false

    - name: Terraform Init
      run: terraform init
      working-directory: ${{ env.TERRAFORM_DIR }}

    - name: Download Terraform Plan
      uses: actions/download-artifact@v3
      with:
        name: tfplan
        path: ${{ env.TERRAFORM_DIR }}

    - name: Terraform Apply
      run: terraform apply -auto-approve tfplan
      working-directory: ${{ env.TERRAFORM_DIR }}
```

## Key Components Explained

### 1. Trigger Configuration
- Push to main (only terraform and workflow files)
- Pull requests to main
- Manual trigger option

### 2. Permissions
- Read repository contents
- Write to pull requests (for comments)
- Write to issues

### 3. Environment Variables
- TF_LOG for debugging
- AWS_REGION from secrets
- TERRAFORM_DIR for workspace path

### 4. Jobs Structure
1. terraform-plan:
   - Runs format check
   - Initializes Terraform
   - Creates and saves plan
   - Comments on PR
   - Uploads plan artifact

2. approval:
   - Manual gate
   - Only runs on main branch
   - Requires production environment approval

3. terraform-apply:
   - Downloads plan artifact
   - Applies saved plan
   - Only runs after approval

### 5. Error Handling
- Plan exit codes:
  - 0 = No changes
  - 1 = Error
  - 2 = Changes present
- continue-on-error where appropriate
- Detailed error messages

### 6. Security Features
- AWS credentials as secrets
- Environment protection rules
- Branch protections
- Limited permissions