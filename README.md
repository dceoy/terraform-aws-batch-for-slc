# terraform-aws-batch-for-slc

Terraform modules of AWS Batch for serverless computing

[![CI](https://github.com/dceoy/terraform-aws-batch-for-slc/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-batch-for-slc/actions/workflows/ci.yml)

## Installation

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-batch-for-slc.git
    $ cd terraform-aws-batch-for-slc
    ```

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Authenticate to the Docker Hardened Images registry using your Docker Hub credentials.
    The local Docker build performed during Terragrunt apply requires this login.

    ```sh
    $ docker login dhi.io
    ```

5.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --terragrunt-working-dir='envs/dev/' -upgrade -reconfigure
    ```

6.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --terragrunt-working-dir='envs/dev/'
    ```

7.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
    ```

## Cleanup

```sh
$ terragrunt run-all destroy --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
```
