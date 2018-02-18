function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"
echo "Config";
echo "==============================";
echo "AWS_REGION: $AWS_REGION":

# Check variables set
[ -z "$AWS_REGION" ] && die "AWS_REGION not set";

echo "> Installing python pip"
sudo apt-get install -y --no-install-recommends python3-pip
[ $? -ne 0 ] && die "Failed to install python pip";

echo "> Upgrade python pip"
  sudo -H pip3 install --upgrade pip
[ $? -ne 0 ] && die "Failed to upgrade python pip";

echo "> Installing setuptools"
sudo -H  pip install setuptools
[ $? -ne 0 ] && die "Failed to install setuptools";

echo "> Installing botocore"
sudo -H pip download botocore==1.8.43
[ $? -ne 0 ] && die "Failed to download botocore";

echo "> Installing aswcli"
sudo -H  pip install awscli
[ $? -ne 0 ] && die "Failed to install aswcli";

echo "> Setting default region to us-east-1"
aws configure set default.region $AWS_REGION
[ $? -ne 0 ] && die "Failed to set default region";

echo "> Setting default output to json"
aws configure set default.output json
[ $? -ne 0 ] && die "Failed to set default output to json";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;
