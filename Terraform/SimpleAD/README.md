In this terraform script, we look to create a simple and small Active Directory service.
We begin by creating 4 subnets, 2 private and 2 public. Of course our directory sits in the private subnets.
We also have an administration server running "Windows Server 2019" in an autoscaling group that connects to the Simple Directory. 
To access our Windows servers we must first go through a bastion host.
