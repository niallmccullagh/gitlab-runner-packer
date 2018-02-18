function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

echo "> Installing jq"
sudo apt-get install -y --no-install-recommends jq
[ $? -ne 0 ] && die "Failed to install jq";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;
