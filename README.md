### SCRIPT TO BRING UP APACHE MESOS ON LOCAL COMPUTE CLUSTER/DATACENTER

Apache Mesos enables us to use clusture of computers as one single computer. It helps us to create an elastic distributed systems to run our compute jobs.  

#### INSTALL MESOS
	
Login to all nodes in the cluster one by one and run the following script to install mesos
	
	$./src/install_mesos.sh

	

#### CONFIG FILE
	
Specify the ip addresss of the chosen master nodes in the config file ( mesos.config ). Copy this config file to all the nodes ( both master and slave ) of your cluster.
	
#### MASTER SETUP
	
Login to all master nodes one by one and run the following script to bringup mesos master [ make sure the script and mesos.config file are in the same directory ]	

	$./src/config_mesos_master.sh

#### SLAVE SETUP
	
Login to the all slave nodes one by one and run the following script to bringup mesos slave [ make sure the script and mesos.config file are in the same directory ]	

	$./src/config_mesos_slave.sh





