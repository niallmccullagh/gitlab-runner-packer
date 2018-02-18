# Gitlab Runner AMI

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
* Gitlab runner configuration - see configuration below
* Kubectl configuration setup - see configuration below

## Build the AMI
 ```bash
 packer build -var 'aws_region=us-east-1' template.json
 ```
 
 ## Run configuration
 The initialisation script `scripts/init/runner-init.sh` should be executed when the instance is first run. It requires the following environment variables set.
 
* **RUNNER_TAG_LIST:** A comma separated list of tags for the runner
* **RUNNER_NAME:** A name to give runner in gitlab
* **REGISTRATION_TOKEN:** The project registration token
* **KUBE_CONFIG_PATH** A path to a kubectl config file within a S3 bucket

The following is an example terraform resource that uses the aws `user_data` configuration value to configure and execute the copied `runner-init.sh` script.

```
resource "aws_instance" "gitlab-runner" {
  count = "1"
  ami           = "${data.aws_ami.gitlab-runner.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.gitlab-runner.name}"]
  user_data       = <<EOF
#!/bin/bash
export RUNNER_TAG_LIST=YOUR_PROJECT_NAME,shell,docker,kubectl,aws
export RUNNER_NAME=myproject-gitlab-runner
export REGISTRATION_TOKEN=YOUR_PROJECT_TOKEN
export KUBE_CONFIG_PATH=s3://YOUR_BUCKET/kubectl/config
/opt/runner-init.sh
EOF
  iam_instance_profile="${aws_iam_instance_profile.gitlab-runner.name}"
  key_name = "${aws_key_pair.gitlab-runner.key_name}"
  associate_public_ip_address = "true"

  tags {
    Name        = "gitlab-runner"
    app         = "gitlab"
    Environment = "engineering"
  }
}
```

Also see the sample terraform project included in this repo.