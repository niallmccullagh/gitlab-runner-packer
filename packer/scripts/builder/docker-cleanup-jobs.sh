echo "Started running $(basename "$0")"
echo "WARN!!! This file may exit with a success incorrectly. Please review ouput"

echo "> Installing crontab to prune docker"
( sudo crontab -l ; echo "0 1 * * * /usr/bin/docker system prune -f" ) | sudo crontab -


echo "> Installing crontab to delete all ECR images daily"
( sudo crontab -l ; echo "0 2 * * * /usr/bin/docker rmi -f \$(/usr/bin/docker images | awk '\$1~/amazonaws.com/ { print \$3 }')" ) | sudo crontab -


# Got this far? Assume we are good
echo "Finished running $(basename "$0")"
exit 0;