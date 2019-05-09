echo "UPLOADING [ "$1" ] to SERVER [ "$2" ]"
rm /Users/viki/.ssh/known_hosts 
scp -i /Users/viki/mesos.pem -r $1 $2:~/
