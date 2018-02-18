function die (){
  echo "$1" 1>&2
  exit 1
}
# Just incase someone opens up aws security group

echo "Started running $(basename "$0")"

echo "> Setting default deny all incoming"
sudo ufw default deny incoming
[ $? -ne 0 ] && die "Failed set default deny all incoming";

echo "> Setting default allow all outgoing"
sudo ufw default allow outgoing
[ $? -ne 0 ] && die "Failed set default allow all outgoing";

echo "> Setting allow ssh incoming"
sudo ufw allow ssh
[ $? -ne 0 ] && die "Failed set allow ssh incoming";

echo "> Enabling UFW"
sudo ufw enable
[ $? -ne 0 ] && die "Failed enable ufw";

echo "> UFW Status"
sudo ufw status verbose

# Got this far? Then we are good
echo "Finished running $(basename "$0")"
exit 0;