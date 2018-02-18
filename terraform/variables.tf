variable "gitlab_runner_tags" {
  description = "A comma separated list of tags for the runner"
}

variable "gitlab_runner_name" {
  description = "The name of the gitlab runner to identify in the UI"
}

variable "gitlab_runner_registration_token" {
  description = "The intial project registration token"
}

variable "ssh_public_key" {
  description = "Public ssh key for the instance"
}