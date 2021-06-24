#!/bin/bash

MASTER="<MASTER-NODE-NAME>"
WORKER1="<WORKER1-NODE-NAME>"
WORKER2="<WORKER2-NODE-NAME>"
BITS="<URL-FOR-ALLUXIO-BITS>"
S3_BUCKET="<S3-BUCKET_URL>"
AWS_CERT_FILE="<LOCAL-CERT-FILE>"
ACCESS_KEY="<AWS-ACCESS-KEY>"
AWS_SECRET="<AWS-SECRET>"

CONFIG_TEMPLATE="./alluxio-site.properties.template"
CONFIG_TEMPLATE="./alluxio-site.properties.template"
CONFIG_FILE="./alluxio-site.properties"
AUTH_FILE="authorized_keys"
MASTER_FILE_TEMP="master.temp"
WORKERS_FILE_TEMP="workers.temp"


setup_ssh() {
	
if [[ -f $AUTH_FILE ]]; then
    rm $AUTH_FILE
fi

echo "* - setting up ssh connections between nodes"
scp -i $AWS_CERT_FILE ec2-user@$MASTER:/home/ec2-user/.ssh/authorized_keys .
#### Generate key and download public key for each node
ssh -i $AWS_CERT_FILE ec2-user@$MASTER ssh-keygen -t rsa 
ssh -i $AWS_CERT_FILE ec2-user@$MASTER chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i $AWS_CERT_FILE ec2-user@$MASTER cat /home/ec2-user/.ssh/id_rsa.pub >> $AUTH_FILE

ssh -i $AWS_CERT_FILE ec2-user@$WORKER1 ssh-keygen -t rsa 
ssh -i $AWS_CERT_FILE ec2-user@$WORKER1 chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i $AWS_CERT_FILE ec2-user@$WORKER1 cat /home/ec2-user/.ssh/id_rsa.pub >> $AUTH_FILE

ssh -i $AWS_CERT_FILE ec2-user@$WORKER2 ssh-keygen -t rsa 
ssh -i $AWS_CERT_FILE ec2-user@$WORKER2 chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i $AWS_CERT_FILE ec2-user@$WORKER2 cat /home/ec2-user/.ssh/id_rsa.pub >> $AUTH_FILE

scp -i $AWS_CERT_FILE ./$AUTH_FILE ec2-user@$MASTER:/home/ec2-user/.ssh/.
ssh -i $AWS_CERT_FILE ec2-user@$MASTER chmod 600 /home/ec2-user/.ssh/authorized_keys
scp -i $AWS_CERT_FILE ./authorized_keys ec2-user@$WORKER1:/home/ec2-user/.ssh/.
ssh -i $AWS_CERT_FILE ec2-user@$WORKER1 chmod 600 /home/ec2-user/.ssh/authorized_keys
scp -i $AWS_CERT_FILE ./authorized_keys ec2-user@$WORKER2:/home/ec2-user/.ssh/.
ssh -i $AWS_CERT_FILE ec2-user@$WORKER2 chmod 600 /home/ec2-user/.ssh/authorized_keys
}

download_bits() {
	echo "* - downloading Alluxio to each node"
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER wget -nv $BITS
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz

	ssh -i $AWS_CERT_FILE ec2-user@$WORKER1  wget -nv $BITS
	ssh -i $AWS_CERT_FILE ec2-user@$WORKER1  tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz

	ssh -i $AWS_CERT_FILE ec2-user@$WORKER2  wget -nv $BITS
	ssh -i $AWS_CERT_FILE ec2-user@$WORKER2  tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz
}

install_jdk() {
	echo "* - Installing Java SDK on each node"
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER sudo yum -y -q install java-1.8.0-openjdk
	ssh -i $AWS_CERT_FILE ec2-user@$WORKER1 sudo yum -y -q install java-1.8.0-openjdk
	ssh -i $AWS_CERT_FILE ec2-user@$WORKER2 sudo yum -y -q install java-1.8.0-openjdk

}

alluxio_config() {
	echo "* - distributing Alluxio config to each node"
if [[ -f $CONFIG_FILE ]]; then
    rm $CONFIG_FILE
	cp $CONFIG_TEMPLATE $CONFIG_FILE
fi
	
	echo "# Common properties" > $CONFIG_FILE
	echo "alluxio.master.hostname="$MASTER >> $CONFIG_FILE
	echo "alluxio.master.mount.table.root.ufs="$S3_BUCKET >>$CONFIG_FILE
	echo "#AWS Properties" >>$CONFIG_FILE
	echo "aws.accessKeyId="$ACCESS_KEY >>$CONFIG_FILE
	echo "aws.secretKey="$AWS_SECRET >> $CONFIG_FILE
	#
	cp $MASTER_FILE_TEMP masters
	cp $WORKERS_FILE_TEMP workers
	echo $MASTER >> masters
	echo $WORKER1 >> workers
	echo $WORKER2 >> workers

	
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER mv /home/ec2-user/alluxio-2.5.0-3/conf/masters /home/ec2-user/alluxio-2.5.0-3/conf/masters.orig
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER mv /home/ec2-user/alluxio-2.5.0-3/conf/workers /home/ec2-user/alluxio-2.5.0-3/conf/workers.orig
	scp -i $AWS_CERT_FILE ./masters ec2-user@$MASTER:/home/ec2-user/alluxio-2.5.0-3/conf/.
	scp -i $AWS_CERT_FILE ./workers ec2-user@$MASTER:/home/ec2-user/alluxio-2.5.0-3/conf/.

	scp -i $AWS_CERT_FILE ./alluxio-site.properties ec2-user@$MASTER:/home/ec2-user/alluxio-2.5.0-3/conf/.
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER /home/ec2-user/alluxio-2.5.0-3/bin/alluxio copyDir /home/ec2-user/alluxio-2.5.0-3/conf/
	ssh -i $AWS_CERT_FILE ec2-user@$MASTER /home/ec2-user/alluxio-2.5.0-3/bin/alluxio formatMasters
}

setup_ssh
download_bits
install_jdk
alluxio_config

echo Config compete !
echo Connect to the master node to start Alluxio
echo ssh -i $AWS_CERT_FILE ec2-user@$MASTER
echo Open web browser to http://$MASTER:19999 to view console
echo Run tests to verify install on the master node:  ./bin/alluxio runTests