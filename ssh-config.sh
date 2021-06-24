#!/bin/bash 

MASTER="ec2-3-22-249-113.us-east-2.compute.amazonaws.com"
WORKER1="ec2-18-117-165-165.us-east-2.compute.amazonaws.com"
WORKER2="ec2-18-224-64-160.us-east-2.compute.amazonaws.com"
BITS="https://mw-alluxio.s3.us-east-2.amazonaws.com/alluxio-2.5.0-3-bin.tar.gz"
S3_BUCKET=""

setup_ssh () {
scp -i "alluxio2.cer" ec2-user@$MASTER:/home/ec2-user/.ssh/authorized_keys .
#### Generate key and download public key for each node
ssh -i "alluxio2.cer" ec2-user@$MASTER ssh-keygen -t rsa 
ssh -i "alluxio2.cer" ec2-user@$MASTER chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i "alluxio2.cer" ec2-user@$MASTER cat /home/ec2-user/.ssh/id_rsa.pub >> authorized_keys

ssh -i "alluxio2.cer" ec2-user@$WORKER1 ssh-keygen -t rsa 
ssh -i "alluxio2.cer" ec2-user@$WORKER1 chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i "alluxio2.cer" ec2-user@$WORKER1 cat /home/ec2-user/.ssh/id_rsa.pub >> authorized_keys

ssh -i "alluxio2.cer" ec2-user@$WORKER2 ssh-keygen -t rsa 
ssh -i "alluxio2.cer" ec2-user@$WORKER2 chmod 600 /home/ec2-user/.ssh/id_rsa
ssh -i "alluxio2.cer" ec2-user@$WORKER2 cat /home/ec2-user/.ssh/id_rsa.pub >> authorized_keys

scp -i "alluxio2.cer" ./authorized_keys ec2-user@$MASTER:/home/ec2-user/.ssh/.
ssh -i "alluxio2.cer" ec2-user@$MASTER chmod 600 /home/ec2-user/.ssh/authorized_keys
scp -i "alluxio2.cer" ./authorized_keys ec2-user@$WORKER1:/home/ec2-user/.ssh/.
ssh -i "alluxio2.cer" ec2-user@$WORKER1 chmod 600 /home/ec2-user/.ssh/authorized_keys
scp -i "alluxio2.cer" ./authorized_keys ec2-user@$WORKER2:/home/ec2-user/.ssh/.
ssh -i "alluxio2.cer" ec2-user@$WORKER2 chmod 600 /home/ec2-user/.ssh/authorized_keys
}

download_bits () {
	ssh -i "alluxio2.cer" ec2-user@$MASTER wget -nv $BITS
	ssh -i "alluxio2.cer" ec2-user@$MASTER tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz

	ssh -i "alluxio2.cer" ec2-user@$WORKER1  wget -nv $BITS
	ssh -i "alluxio2.cer" ec2-user@$WORKER1  tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz

	ssh -i "alluxio2.cer" ec2-user@$WORKER2  wget -nv $BITS
	ssh -i "alluxio2.cer" ec2-user@$WORKER2  tar -xvpf ./alluxio-2.5.0-3-bin.tar.gz
}

install_jdk() {
	ssh -i "alluxio2.cer" ec2-user@$MASTER sudo yum -y -q install java-1.8.0-openjdk
	ssh -i "alluxio2.cer" ec2-user@$WORKER1 sudo yum -y -q install java-1.8.0-openjdk
	ssh -i "alluxio2.cer" ec2-user@$WORKER2 sudo yum -y -q install java-1.8.0-openjdk

}

alluxio_config() {
	scp -i "alluxio2.cer" ./alluxio-site.properties ec2-user@$MASTER:/home/ec2-user/alluxio-2.5.0-3/conf/.
	ssh -i "alluxio2.cer" ec2-user@$MASTER /home/ec2-user/alluxio-2.5.0-3/bin/alluxio copyDir /home/ec2-user/alluxio-2.5.0-3/conf/
	ssh -i "alluxio2.cer" ec2-user@$MASTER /home/ec2-user/alluxio-2.5.0-3/bin/alluxio formatMasters
}
#setup_ssh
#download_bits
#install_jdk
alluxio_config

