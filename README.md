## Script to bring up Apache Mesos on local computing cluster 

Apache Mesos enables us to use clusture of computers as one single computer. It helps us to create an elastic distributed systems to run our compute jobs.  

#### Install Mesos on all nodes in the cluster
	
	Login to nodes one by one and run the following script to install mesos.
	
	$./src/install_mesos.sh

	

#### Config File [ mesos.config ]
	
	Specify the ip addresss of the chosen master nodes in the config file. Copy this config file to all the nodes(both master and slave) in the local cluster.
	
#### Bring up master node
	
	Login to the master nodes one by one and run the following script to bringup mesos master [ make sure the script and mesos.config file are in the same directory ]	

	$./src/config_mesos_master.sh

#### Bring up slave node
	
	Login to the slave nodes one by one and run the following script to bringup mesos slave [ make sure the script and mesos.config file are in the same directory ]	

	$./src/config_mesos_slave.sh





