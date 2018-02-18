function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

echo "> Installing kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
[ $? -ne 0 ] && die "Failed to install kubectl";

echo "> Enable execution for kubectl"
chmod +x ./kubectl
[ $? -ne 0 ] && die "Failed to enable execution for kubectl";

echo "> Moving kubectl to /usr/local/bin"
sudo mv ./kubectl /usr/local/bin/kubectl
[ $? -ne 0 ] && die "Failed to move kubectl";

echo "> Creating /home/gitlab-runner/.kube directory"
sudo -u gitlab-runner mkdir -p /home/gitlab-runner/.kube
[ $? -ne 0 ] && die "Failed to create /home/gitlab-runner/.kube directory";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;