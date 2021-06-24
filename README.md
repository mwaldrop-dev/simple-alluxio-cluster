# simple-alluxio-cluster
This project provides a very simple deployment script to create a 3 node cluster to AWS with Alluxio installed and configured.  This is NOT an implementation of best practices for any production workload.  Many simplifications are made and assumed to keep this simple.

The end result of using this script will be a singe master node and 2 worker nodes configured to run Alluxio against an S3 understore.

The launchCluster.sh script needs a few things to be in place in order to function:
1) Make sure you have an AWS access key file that allows you to create and connect to EC2 instances.
2) Create a security group with a few very simple rules:
<img src="docImages/EC2_Management_Console.png">
3)Make sure you have your AWSAccessKeyId and AWSSecretKey values.  For the most simple case, you can create your own 'root access' credentials under the "Access Keys" section of your security credentials in the AWS console.
4) Create an S3 bucket and a folder within that bucket.  This is what Alluxio will use as an understore:
<img src="docImages/s3Buckets.png">
5) Now we will launch 3 EC2 nodes.  Simply launch 3 instances of t2.large, use your access key, update the storage to 12GB, select your security group, and launch the instances.
<img src="docImages/select_instance_type.png">

<img src="docImages/instance_type.png">

<img src="docImages/instace_details.png">

<img src="docImages/securityGroup.png">

<img src="docImages/storageScreen.png">




