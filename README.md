# magento2-github-actions

## Coding Standard
Update version of graycoreio to include cs2pr output

## Update Changelog
On each release, the file CHANGELOG.md is updated with the content of the release tag.

## ECR
Build Docker image and push it on Amazon Elastic Container Registry

### Usage
Create a file in your repo like .github/workflows/build-image.yml
with the content for example

```
name: Build Docker & Push
on:
  push:
    tags:
      - '**'
  workflow_dispatch:

jobs:
  Build-image:
    name: Build Docker Image
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker Image and push to ECR
        uses: HSF-Digital-Team/github-actions/ECR@main
        with:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{secrets.AWS_REGION}}
          AWS_ECR_REPO: ${{secrets.AWS_ECR_REPO}}
```

Add the secret to your repo or organisation Level :
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION (default is eu-west-3)
- AWS_ECR_REPO

## DeployOpsworks

### Usage
This action will launch a deploy on Opsworks.
Need to add the secret AWS_STACK_NAME with the stack name retrieved from AWS console.
```
name: Deploy to OpsWorks
on:
  workflow_dispatch:

jobs:
  Deploy-opsworks:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to OpsWorks
        uses: HSF-Digital-Team/github-actions/DeployOpsworks@main
        with:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{secrets.AWS_REGION}}
          AWS_STACK_NAME: ${{secrets.AWS_STACK_NAME}}
```
