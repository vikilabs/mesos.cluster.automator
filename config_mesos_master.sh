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

configure_zookeeper(){
	echo " [ CONFIGURING MASTER ID ] [ CURRENT MASTER ID = $MASTER1 ] "
	echo $CURRENT_MASTER | sudo tee /etc/zookeeper/conf/myid

	echo ""
	echo "[ UPDATING MESOS MASTER INFORMATION TO ZOOKEEPER ]"
	echo ""
	ZOOKEEPER_CFG="/etc/zookeeper/conf/zoo.cfg"
	sudo cp /etc/zookeeper/conf/zoo.cfg /etc/zookeeper/conf/.#zoo.cfg
	sudo sed -i '/server.1/c #server.1' $ZOOKEEPER_CFG
	sudo sed -i '/server.2/c #server.2' $ZOOKEEPER_CFG
	sudo sed -i '/server.3/c #server.3' $ZOOKEEPER_CFG

	if [ $MASTER1 ]; then 
		sudo sed -i "/server.1/c server.1=$MASTER1_IP:2888:3888" $ZOOKEEPER_CFG
	fi

	if [ $MASTER2 ]; then 
		sudo sed -i "/server.2/c server.2=$MASTER2_IP:2888:3888" $ZOOKEEPER_CFG
	fi	

	if [ $MASTER3 ]; then 
		sudo sed -i "/server.3/c server.3=$MASTER3_IP:2888:3888" $ZOOKEEPER_CFG		
	fi
	echo ""
}

MESOS_INIT_CFG="/etc/systemd/system/mesos-master.service"     

configure_mesos_master(){
	#set quorum to 1
	MESOS_MASTER_PATH=`which mesos-master`
	echo "[ SETTING QUORUM ]"
	echo "1" | sudo tee "/etc/mesos-master/quorum"

	echo "[ CREATING INIT.D FOR MESOS MASTER ]"

	echo "[Unit]" | sudo tee $MESOS_INIT_CFG
 	echo "Description=Mesos Master Service" | sudo tee -a $MESOS_INIT_CFG
    echo "After=zookeeper.service" | sudo tee -a $MESOS_INIT_CFG
    echo "Requires=zookeeper.service" | sudo tee -a $MESOS_INIT_CFG
    echo "" | sudo tee -a $MESOS_INIT_CFG
    echo "[Service]" | sudo tee -a $MESOS_INIT_CFG
    echo "ExecStart=$MESOS_MASTER_PATH --ip=$MASTER1_IP --work_dir=/var/lib/mesos --zk=$ZK_VAR/mesos --quorum=1  --cluster=$CLUSTER_NAME" | sudo tee -a $MESOS_INIT_CFG
	echo "" | sudo tee -a $MESOS_INIT_CFG
	echo "[Install]" | sudo tee -a $MESOS_INIT_CFG
	echo "WantedBy=multi-user.target" | sudo tee -a $MESOS_INIT_CFG

}

MARATHON_INIT_CFG="/etc/systemd/system/marathon.service"
configure_marathon(){
	MARATHON_PATH=`which marathon`
	echo "[Unit]" | sudo tee $MARATHON_INIT_CFG
	echo "Description=Marathon Service" | sudo tee -a $MARATHON_INIT_CFG
	echo "After=mesos-master.service" | sudo tee -a $MARATHON_INIT_CFG
	echo "Requires=mesos-master.service" | sudo tee -a $MARATHON_INIT_CFG
	echo "" | sudo tee -a $MARATHON_INIT_CFG
	echo "[Service]" | sudo tee -a $MARATHON_INIT_CFG
	echo "ExecStart=$MARATHON_PATH --master $ZK_VAR/mesos --zk $ZK_VAR/marathon" | sudo tee -a $MARATHON_INIT_CFG
	echo "" | sudo tee -a $MARATHON_INIT_CFG
	echo "[Install]" | sudo tee -a $MARATHON_INIT_CFG
	echo "WantedBy=multi-user.target" | sudo tee -a $MARATHON_INIT_CFG

}

check_services_status(){
	journalctl -f -u mesos-master.service
	journalctl -f -u marathon.service
}

disable_mesos_master(){
	sudo service mesos-master stop
	#echo "manual" | sudo tee /etc/init/mesos-master.override
}

disable_zookeeper(){
	sudo service zookeeper stop
	#echo "manual" | sudo tee /etc/init/zookeeper.override
}

disable_marathon(){
	 sudo service marathon stop
	 #echo "manual" | sudo tee /etc/init/marathon.override
}

disable_mesos_slave(){
	sudo service mesos-slave stop
 	echo "manual" | sudo tee /etc/init/mesos-slave.override	
}

enable_zookeeper(){
	echo "[ STARTING ZOOKEEPER ]"
    sudo systemctl start zookeeper
    sudo systemctl enable zookeeper
}

enable_mesos_master(){
	echo "[ STARTING MESOS MASTER ]"
	sudo systemctl daemon-reload
	sudo systemctl start mesos-master.service
	sudo systemctl enable mesos-master.service	
}

enable_marathon(){
	echo "[ STARTING MARATHON ]"
	sudo systemctl daemon-reload
	sudo systemctl start marathon.service
	sudo systemctl enable marathon.service	
}

validate_config
disable_mesos_slave
disable_marathon
disable_mesos_master
disable_zookeeper

configure_zookeeper
configure_mesos_master
configure_marathon

enable_zookeeper
enable_mesos_master
enable_marathon

#check_services_status
