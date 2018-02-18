# Gitlab Runner AMI


## Packer

Builds and configures an AMI with:

**Infra**
* Updates to latest packages and enables auto update of security packages
* firewall allowing only ssh incoming

**Tools**

* docker
* kubectl
* aws cli
* gitlab runner
* jq
* docker cleanup jobs

**Initialisation**
* Gitlab runner configuration
* Kubectl configuration setup


See [Packer Readme](./packer/README.md) for more details


## Terraform

A sample terraform project to show how to deploy the AMI into AWS.

See [Terraform Readme](./terraform/README.md) for more details


## Requirements

* a [AWS account](https://aws.amazon.com/) (**Be careful this template implies creating billable resources on AWS cloud**)
You will need an [AWS access key](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and enough admin permissions to create AWS ressources
* a SSH Key pair to connect to Gitlab and AWS instances (see [Github help for examples](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/))
* [Packer](https://www.packer.io/) >= 1.1.3
* [Terraform](https://www.terraform.io/) >= v0.11.2


## Usage


1. Build the iamge `cd packer; packer build -var 'aws_region=us-east-1' template.json`. See [Packer Readme](./packer/README.md) for more details
1. Create `kube-config` file which contains configuration to access your cluster.
1. Run `terrafrom init; terraform apply`, set variables, review changes and confirm by typing `yes`. See [Terraform Readme](./terraform/README.md) for more details  