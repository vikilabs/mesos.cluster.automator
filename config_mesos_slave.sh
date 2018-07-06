#!/bin/bash
#Author: Vignesh Natrajan (viki@vikilabs.in)

source ./mesos.config

MASTER1=$MASTER_1_UNIQUE_ID #always the current master id
MASTER2=$MASTER_2_UNIQUE_ID
MASTER3=$MASTER_3_UNIQUE_ID
MASTER4=$MASTER_4_UNIQUE_ID
MASTER1_IP=$MASTER_1_IP_ADDRESS
MASTER2_IP=$MASTER_2_IP_ADDRESS
MASTER3_IP=$MASTER_3_IP_ADDRESS

CURRENT_MASTER=$MASTER1
CURRENT_MASTER_IP=$MASTER1_IP
ZK_VAR="zk://"

validate_config(){
	echo ""
	echo "[ MESOS CONFIGURATION ]"

	if [ $MASTER1 ]; then 
    	echo "    MASTER [ID : $MASTER1 ] [ IP : $MASTER_1_IP ]"
		ZK_VAR=$ZK_VAR$MASTER1_IP":2181"
	fi


	if [ $MASTER2 ]; then 
    	echo "    MASTER [ID : $MASTER2 ] [ IP : $MASTER_2_IP ]"
		ZK_VAR=$ZK_VAR","$MASTER2_IP":2181"
	fi


	if [ $MASTER3 ]; then 
    	echo "    MASTER [ID : $MASTER3 ] [ IP : $MASTER_3_IP ]"
		ZK_VAR=$ZK_VAR","$MASTER3_IP":2181"
	fi


	#echo "[ VALIDATING  MESOS MASTER CONFIGURATION ]"
	echo ""
}

MESOS_SLAVE_CFG="/etc/systemd/system/mesos-slave.service"
configure_mesos_slave(){
	echo "[ CREATING INIT.D FOR MESOS SLAVE ]"
	MESOS_SLAVE_PATH=`which mesos-slave`

	echo "[Unit]" | sudo tee $MESOS_SLAVE_CFG
	echo "Description=Mesos Slave Service" | sudo tee -a $MESOS_SLAVE_CFG
	echo "" | sudo tee -a $MESOS_SLAVE_CFG
	echo "[Service]" | sudo tee -a $MESOS_SLAVE_CFG
	echo "ExecStart=$MESOS_SLAVE_PATH --master=$ZK_VAR/mesos --work_dir=/var/lib/mesos" | sudo tee -a $MESOS_SLAVE_CFG
	echo "" | sudo tee -a $MESOS_SLAVE_CFG
	echo "[Install]" | sudo tee -a $MESOS_SLAVE_CFG
	echo "WantedBy=multi-user.target" | sudo tee -a $MESOS_SLAVE_CFG

}

disable_mesos_master(){
	sudo service mesos-master stop
	echo "manual" | sudo tee /etc/init/mesos-master.override
}

disable_zookeeper(){
	sudo service zookeeper stop
	echo "manual" | sudo tee /etc/init/zookeeper.override
}

disable_marathon(){
	 sudo service marathon stop
	 echo "manual" | sudo tee /etc/init/marathon.override
}

disable_mesos_slave(){
	sudo service mesos-slave stop
 	#echo "manual" | sudo tee /etc/init/mesos-slave.override	
}

enable_mesos_slave(){
	sudo systemctl daemon-reload
	sudo systemctl start mesos-slave.service
	sudo systemctl enable mesos-slave.service
}

check_services_status(){
    journalctl -f -u mesos-slave.service
}

validate_config
disable_marathon
disable_mesos_master
disable_mesos_slave
disable_zookeeper
configure_mesos_slave
enable_mesos_slave
#check_services_status
