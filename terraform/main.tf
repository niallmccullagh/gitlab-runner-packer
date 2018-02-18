provider "aws" {
  version = "~> 1.7"
  region  = "us-east-1"
}

resource "aws_kms_key" "ci-config" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10

  tags {
    app         = "gitlab"
    Environment = "engineering"
  }
}

resource "aws_kms_alias" "ci-config" {
  name          = "alias/ci-config"
  target_key_id = "${aws_kms_key.ci-config.key_id}"
}

#
# Configure a bucket to hold the configuration.
#
resource "aws_s3_bucket" "ci-config" {
  acl    = "private"
  bucket_prefix="ci"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.ci-config.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    app         = "gitlab"
    Environment = "engineering"
  }
}

#
# Upload kube config to bucket
#
resource "aws_s3_bucket_object" "kube_config" {
  key        = "kubectl/config"
  bucket     = "${aws_s3_bucket.ci-config.id}"
  source     = "./kube-config"
  kms_key_id = "${aws_kms_key.ci-config.arn}"
}

#
# IAM Role for runner
#

resource "aws_iam_role" "gitlab-runner" {
  name = "gitlab-runner"
  path = "/"
  description = "Allows EC2 instances in an ECS cluster to access ECS."

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [{
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }]
}
EOF
}

resource "aws_iam_instance_profile" "gitlab-runner" {
  name  = "gitlab-runner"
  role = "${aws_iam_role.gitlab-runner.name}"
}


data "aws_iam_policy_document" "ci-config" {
  policy_id = "__default_policy_ID"

  statement {
    actions = ["kms:Decrypt"]

    effect = "Allow"

    resources = [
      "${aws_kms_key.ci-config.arn}"
    ]

    sid = "AllowToDecryptUsingConfigKey"
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.ci-config.arn}",
      "${aws_s3_bucket.ci-config.arn}/*"
    ]

    sid = "AllowReadFromConfigBucket"
  }
}

resource "aws_iam_policy" "ci-config" {
  name        = "read-ci-config"
  path        = "/"
  description = "Read and decrypt CI Config"
  policy = "${data.aws_iam_policy_document.ci-config.json}"
}

resource "aws_iam_role_policy_attachment" "gitlab-runner_ci-config" {
  role       = "${aws_iam_role.gitlab-runner.name}"
  policy_arn = "${aws_iam_policy.ci-config.arn}"
}

#
# Create instance
#
data "aws_caller_identity" "current" {}

data "aws_ami" "gitlab-runner" {
  most_recent = true

  filter {
    name   = "name"
    values = ["gitlab_runner-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${data.aws_caller_identity.current.account_id}"]
}


resource "aws_security_group" "gitlab-runner" {

  name        ="gitlab-runner"
  description = "Gitlab runer"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags {
    app         = "gitlab"
    Environment = "engineering"
  }
}

resource "aws_key_pair" "gitlab-runner" {
  key_name   = "gitlab-runner-key"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "gitlab-runner" {
  count = "1"
  ami           = "${data.aws_ami.gitlab-runner.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.gitlab-runner.name}"]
  user_data       = <<EOF
#!/bin/bash
export RUNNER_TAG_LIST=${var.gitlab_runner_tags}
export RUNNER_NAME=${var.gitlab_runner_name}
export REGISTRATION_TOKEN=${var.gitlab_runner_registration_token}
export KUBE_CONFIG_PATH=s3://${aws_s3_bucket.ci-config.id}/kubectl/config
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
