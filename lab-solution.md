1. fork the repo
2. check action was created and ran
3. generate aws access keys
4. Create repository secrets
5. create environment to gh-actions-lab
6. add your user account to required reviewers in the environment
5. set aws region to us-east-1 in secrets 
5. setup aws cli
6. add config to ~/.aws/credentials 
[gh-actions-lab]
aws_access_key_id = YOUR_DEFAULT_ACCESS_KEY
aws_secret_access_key = YOUR_DEFAULT_SECRET_KEY
6. export AWS_PROFILE=gh-actions-lab
6. create s3 backend
7. aws s3 mb s3://my-terraform-state-bucket --region us-east-1 (must be globally unique)
8. change backend in main/backend.tf to use the s3 bucket
9. add your user to the approvers list in the approval step
10. push code to main branch
11. review the plan and approve if you want to apply the changes
12. check the resources were created in the console
