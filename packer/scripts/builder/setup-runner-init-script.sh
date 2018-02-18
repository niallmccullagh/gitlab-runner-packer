function die (){
  echo "$1" 1>&2
  exit 1
}

echo "Started running $(basename "$0")"

echo "> Moving init script"
sudo mv /tmp/runner-init.sh /opt/runner-init.sh
[ $? -ne 0 ] && die "Failed to move init script";

echo "> Enable execution for init script"
sudo chmod +x /opt/runner-init.sh
[ $? -ne 0 ] && die "Failed to enable execution for init script";

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;