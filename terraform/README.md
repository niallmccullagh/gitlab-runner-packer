# Terraform - Gitlab Runner 

A sample Terraform project that sets up a gitlab runner

## What is does

1. Creates an encrypted bucket to store CI configuration
1. Copies the kubectl configuration file `kube-config` to the bucket. **Note:** Create this file before running.
1. Creates a role `gitlab-runner` for the instance 
1. Grants the role to access to decrypt and read the bucket contents
1. Creates a security group for the runners
1. Creates the gitlab instance from the latest AMI that was built using packer

       
## Applying the configuration
1. Initialise terraform by running `terraform init`
1. Plan the execution `terraform plan`
1. Answer the questions, or cancel and add a config file. See `Varibale file below`
1. Review the plan to ensure changes are expected
1. Execute the plan `terraform apply`


### Variable file

Rather than being prompted for the values of the variable's each time.

Create a file named `config.tfvars` and add the following properties replacing the values with yours. 
```prettier
gitlab_runner_tags={{REPLACE_WITH_A_COMMA_SEPERATED_LIST_OF_TAGS_FOR_THE_RUNNER}}
gitlab_runner_name={{REPLACE_WITH_A_NAME_FOR_YOUR_RUNNER}}
gitlab_runner_registration_token={{REPLACE_WITH_YOUR_INITIAL_PROJECT_TOKEN}}
ssh_public_key={{REPLACE_WITH_THE_PUBLIC_PART_OF_YOUR_SSH_KEY}}
 ```

Run terraform referencing the file `terraform apply -var-file=config.tfvars`. 
    

### Getting the gitlab runner ip address

To get the ip address(es) of the runners that are start
```bash
$ aws ec2 describe-instances --filters "Name=tag:Name,Values=gitlab-runner" "Name=instance-state-name,Values=running" | jq -r .Reservations[].Instances[].PublicIpAddress
```