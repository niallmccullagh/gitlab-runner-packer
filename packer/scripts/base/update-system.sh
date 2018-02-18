function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

# Update all
echo "> Updating package list"
sudo apt-get update -y
[ $? -ne 0 ] && die "Failed to update package list";

echo "> Upgrading packages"
# The switches below ensure that we are in noninteractive mode
# Simply passing -y to apt-get does not work when UCF uses debconf
# for prompting.
#
# Check if the package being installed: 
# 1) specifies by default that the new configuration file should be installed - if that is the case, then the new configuration file will be installed and overwrite the old one.
# 2) does not specify by default that the new configuration file should be installed, then the old configuration file would be kept - that is very useful, specially when you customized the installation of that package.

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade
[ $? -ne 0 ] && die "Failed to ugrade packages";


# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;