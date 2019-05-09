#!/bin/bash
#Author: Vignesh Natrajan (viki@vikilabs.in)
#For Both Master and Slave Nodes

#This script is tested for ubuntu 16.04
echo "Install this script in all the nodes of the cluster"
echo "After Installation use mesos_master_config.sh to setup master nodes"
echo "After Installation use mesos_slave_config.sh to setup slave nodes"
echo "Mesos topologu can be feeded into mesos.config"

proxy_host=""
proxy_port=""
CPU_CORES=8

MAVEN_PATH="/usr/share/maven/conf"
MAVEN_CONFIG_FILE="settings.xml"

check_command_status(){
    if [ $? -eq 0 ]; then
        echo
        echo "{ COMMAND STATUS }    [ LINE NO: $1 ]    [ SUCCESS ]    [ CONTINUE ]"
        echo
    else
        echo
        echo "{ COMMAND STATUS }    [ LINE NO: $1 ]    [ FAILURE ]    [ EXITTING ]"
        echo
        exit 1
    fi
}

update_maven_proxy_configuration(){
	#This update is required to install mesos in systems with PROXY settings
	echo "[ UPDATING MAVEN PROXY CONFIG ]"
read -d '' VAR << END  
        <!-- ADDED BY VIKI MESOS INSTALLER -->
        <proxy>
            <active>true</active>
            <protocol>http</protocol>
            <host>$proxy_host</host>
            <port>$proxy_port</port>
        </proxy>
END
	echo "[ MAVEN PROXY START ]"
	echo "$VAR"
	echo "[ MAVEN PROXY END ]"
        echo "$VAR" > /tmp/.maven_proxy.cfg
    	check_command_status ${LINENO}
        sudo sed  -i "/<proxies>/r /tmp/.maven_proxy.cfg" $MAVEN_PATH/$MAVEN_CONFIG_FILE
    	check_command_status ${LINENO}
        #sudo rm /tmp/.maven_proxy.cfg
    	check_command_status ${LINENO}
}

check_proxy_config_and_update_maven(){
    if [ $http_proxy ]; then
        echo "PROXY CONFIGURED = "$http_proxy
    	echo "[ UPDATING MAVEN PROXY SETTINGS ]"
    	tmp_str=`echo $http_proxy | awk -F '//' '{print $2}'`
    	check_command_status ${LINENO}
   	proxy_host=`echo $tmp_str | awk -F ':' '{print $1}'`
    	proxy_port=`echo $tmp_str | awk -F ':' '{print $2}'`

    	echo "proxy_host = "$proxy_host
    	echo "proxy_port = "$proxy_port
                           
    	sudo cp $MAVEN_PATH/$MAVEN_CONFIG_FILE $MAVEN_PATH/.$MAVEN_CONFIG_FILE
    	check_command_status ${LINENO}
    	update_maven_proxy_configuration
    else
	echo "NO PROXY CONFIG UPDATE REQUIRED"
    fi
}


install_mesos_dependencies(){
    #required for mesos
    sudo apt-get -y update
    check_command_status ${LINENO}
    sudo apt-get -y upgrade
    check_command_status ${LINENO}
    sudo apt-get -y install python
    check_command_status ${LINENO}
    sudo apt-get -y install python-setuptools
    check_command_status ${LINENO}
    sudo easy_install pip
    check_command_status ${LINENO}

    sudo apt-get -y install tar wget git
    check_command_status ${LINENO}
    sudo apt-get -y install openjdk-8-jdk
    check_command_status ${LINENO}
    sudo apt-get -y install autoconf libtool
    check_command_status ${LINENO}
    sudo apt-get -y install build-essential
    check_command_status ${LINENO}
    sudo apt-get -y install python-dev python-six
    check_command_status ${LINENO}
    sudo apt-get -y install python-virtualenv libcurl4-nss-dev
    check_command_status ${LINENO}
    sudo apt-get -y install libsasl2-dev libsasl2-modules maven
    check_command_status ${LINENO}
    sudo apt-get -y install libapr1-dev libsvn-dev zlib1g-dev iputils-ping

    sudo apt -y install unzip
    check_command_status ${LINENO}


    #Update MAVEN config file, if proxy configured in the system	
    check_proxy_config_and_update_maven
}

install_zookeeper(){
	sudo apt -y install zookeeperd
    check_command_status ${LINENO}
}

install_mesos(){
    # Setup
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
    check_command_status ${LINENO}

    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    check_command_status ${LINENO}
    CODENAME=$(lsb_release -cs)
    check_command_status ${LINENO}

    # Add the repository
    echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
    check_command_status ${LINENO}
    sudo apt-get -y update
    check_command_status ${LINENO}
    #sudo apt-get -y install mesos marathon
    wget http://archive.apache.org/dist/mesos/1.6.0/mesos-1.6.0.tar.gz
    check_command_status ${LINENO}
    tar -zxvf mesos-1.6.0.tar.gz
    check_command_status ${LINENO}
    cd mesos-1.6.0
    check_command_status ${LINENO}
    mkdir build
    check_command_status ${LINENO}
    cd build
    check_command_status ${LINENO}
    ../configure
    check_command_status ${LINENO}
    make -j $CPU_CORES V=0
	#make with multiple cores
    #make -j <number of cores> V=0
    check_command_status ${LINENO}
    #make check
    sudo make install 
    check_command_status ${LINENO}
	
    #Install Mesos Python Bindings [mesos-1.6.0/build/src/python/dist]
    cd src/python/dist

	echo "[ Installing Mesos Python Binding ]"
    #Install mesos.egg mesos.cli.egg mesos.executor.egg  mesos.interface.egg
    #Install mesos.native mesos.scheduler 
 	sudo easy_install mesos.scheduler*.egg
    check_command_status ${LINENO}

	sudo easy_install mesos.executor*.egg
    check_command_status ${LINENO}

 	sudo easy_install mesos.native*.egg
    check_command_status ${LINENO}

	sudo easy_install mesos.cli*.egg
    check_command_status ${LINENO}

	sudo easy_install mesos.interface*.egg
    check_command_status ${LINENO}

	sudo easy_install mesos-*.egg
    check_command_status ${LINENO}

}

install_marathon(){
    sudo apt-get -y install marathon
}

install_mesos_dependencies
install_zookeeper
install_mesos
install_marathon


