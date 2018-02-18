#!/bin/bash
################################################################################################
# FUNCTIONS
################################################################################################
function die (){
  echo "$1" 1>&2
  exit 1
}

function check() {
  [ -z "$RUNNER_TAG_LIST" ] && die "RUNNER_TAG_LIST not set";
  [ -z "$RUNNER_NAME" ] && die "RUNNER_NAME not set";
  [ -z "$REGISTRATION_TOKEN" ] && die "REGISTRATION_TOKEN not set";
  [ -z "$KUBE_CONFIG_PATH" ] && die "KUBE_CONFIG_PATH not set";
}

function info() {
    echo " *** INFO ***";
    echo "RUNNER_NAME: $RUNNER_NAME";
    echo "RUNNER_TAG_LIST: $RUNNER_TAG_LIST";
    echo "REGISTRATION_TOKEN: $REGISTRATION_TOKEN";
    echo "KUBE_CONFIG_PATH: $KUBE_CONFIG_PATH"
    echo " ************";
}

echo "Started running $(basename "$0")"
info
check

echo "Registering gitlab runner"
gitlab-runner register --non-interactive -u https://gitlab.com/ --run-untagged=false --executor shell
[ $? -ne 0 ] && die "Failed to register gitlab runner";

echo "Get Kubectl config"
aws s3 cp $KUBE_CONFIG_PATH /home/gitlab-runner/.kube/config
[ $? -ne 0 ] && die "Failed to get kube config";

echo "> Change kube config ownership"
sudo chown gitlab-runner:gitlab-runner /home/gitlab-runner/.kube/config
[ $? -ne 0 ] && die "Failed to change kube config ownership";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;