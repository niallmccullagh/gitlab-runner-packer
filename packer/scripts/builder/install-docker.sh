function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

echo "> Installing docker"
curl -sSL https://get.docker.com/ | sh
[ $? -ne 0 ] && die "Failed to install docker";

echo "> Installing docker compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
[ $? -ne 0 ] && die "Failed to install docker compose";

echo "> Enable execution for docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
[ $? -ne 0 ] && die "Failed to enable execution for docker compose";

echo "> Giving gitlab-runner ability to use docker"
sudo usermod -aG docker gitlab-runner
[ $? -ne 0 ] && die "Failed to give gitlab-runner ability to use docker";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;