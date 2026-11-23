# Waldur → GitHub Actions → AWS EC2 starter

**Status:** Phase 1: GitHub Actions manual provisioning only. Waldur order dispatch and callbacks are **not implemented yet**.

This repository provides a safe starting point for an AWS Research Compute proof of concept. A GitHub Actions workflow assumes a scoped AWS IAM role through OIDC, provisions an EC2 instance with Terraform into an existing approved subnet/security group, and returns non-secret connection metadata as workflow outputs. Each resource uses its own S3 state key.

## Fork into the work account

Fork `swissboy76/awstest` into your work GitHub account. **Do not run against the University AWS account from this personal repository.** Keep AWS account IDs, role ARNs, University networking details, secrets and Terraform state in your work environment.

## Prerequisites

1. An approved AWS account/region, a known-good x86_64 AMI for Ubuntu, existing subnet and security group (no SSH inbound rules created).
2. Encrypted, versioned S3 Terraform state bucket, appropriate S3 permissions and a locking strategy.
3. AWS IAM OIDC provider `https://token.actions.githubusercontent.com` with audience `sts.amazonaws.com`.
4. A least-privilege AWS deployment role with a trust policy scoped to the **work** repository and GitHub environments. See `aws/oidc-trust-policy.example.json`. No administrator role.
5. Access via approved internal routing or an existing AWS Systems Manager Session Manager setup, rather than exposing SSH.

## Set up GitHub in the work fork

Create environments **aws-poc** and **aws-poc-destroy** in Settings → Environments. Limit deployment branches and require reviewers for destruction. Configure these Actions variables at repository level or in *both* environments:

| Variable | Description |
|---|---|
| `AWS_ROLE_ARN` | IAM role assumed via GitHub OIDC |
| `AWS_REGION` | Region (such as `eu-west-2`) |
| `TF_STATE_BUCKET` | Existing encrypted/versioned S3 bucket |
| `AWS_SUBNET_ID` | Existing approved subnet |
| `AWS_SECURITY_GROUP_ID` | Existing approved security group |
| `AWS_AMI_ID` | Region-specific approved Ubuntu AMI ID |

The example trust policy is for environment-scoped GitHub OIDC subjects such as `repo:WORK_OWNER/awstest:environment:aws-poc`, not a branch-based subject. Edit the placeholder owner and account ID; protect the GitHub environments and validate permissions with the University's AWS team.

## Run

In the work repository, open **Actions → Provision research EC2 (manual POC)** and run with a unique `resource_uuid`. Terraform state is isolated at `waldur/<resource_uuid>/terraform.tfstate`. After the job completes, view the summary or the `terraform-outputs-...` artifact for the instance ID and addresses. A public IP is not guaranteed.

To remove an instance, choose **Destroy research EC2 (manual POC)** using the **same exact** resource UUID. Configure reviewer approvals in the destroy environment.

The instance, EBS volume, networking and S3 may incur costs. Set cost controls and destroy resources when finished.

## Next: Waldur integration

The workflows currently use manual dispatch. Next we'll create a Waldur Script offering and a small provisioner to accept authorised resource lifecycle events, dispatch the GitHub workflow, retrieve outputs, populate the Waldur resource's backend ID/endpoints, and implement error handling and termination. This requires confirming the exact Waldur 8.1.4 API and offering capabilities first.

**Security:** Do not commit institution-specific configuration, secrets, private keys or state files. Do not enable public SSH ingress. 
