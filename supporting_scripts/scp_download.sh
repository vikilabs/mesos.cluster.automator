echo "DOWNLOADING [ "$1" ] from SERVER [ "$2" ]"
rm /Users/viki/.ssh/known_hosts 
scp -i /Users/viki/mesos.pem -r $2:$1 .
