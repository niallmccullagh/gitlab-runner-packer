function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

echo "> Add gitlab repository"
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | sudo bash
[ $? -ne 0 ] && die "Failed add gitlab repository";

echo "> Installing gitlab runner"
sudo apt-get install -y gitlab-ci-multi-runner
[ $? -ne 0 ] && die "Failed to install gitlab runner";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;