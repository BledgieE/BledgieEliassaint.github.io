provider "aws" {

region = "us-east-1"
shared_credentials_file = "~/.aws/credentials"
}


#Create intial vpc
resource "aws_vpc" "Main" {
  cidr_block  = "10.0.0.0/16"
  tags = {
    Name = "Main-vpc"
  }
}

#Create Internent Gateway
resource "aws_internet_gateway" "Main_IG" {
  vpc_id = aws_vpc.Main.id
  tags = {
    "Name" = "Main_Internet_Gateway"
  }
}

# Create subnets (2 private and 2 public)
resource "aws_subnet" "Main_Pub_1" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1d"
    map_public_ip_on_launch = true

    tags = {
        Access = "Public"
    }
}

resource "aws_subnet" "Main_Pub_2" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Access = "Public"
    }
}

resource "aws_subnet" "Main_Priv_1" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private_Subnet"
    }
}

resource "aws_subnet" "Main_Priv_2" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private_Subnet_2"
    }
}

#Create SimpleAD 
resource "aws_directory_service_directory" "SimpleAD" {
  name     = "corp.notexample.com"2
  password = "SuperSecretPassw0rd"
  size     = "Small"

  vpc_settings {
    vpc_id     = aws_vpc.Main.id
    subnet_ids = [aws_subnet.Main_Priv_1.id, aws_subnet.Main_Priv_2.id]
  }

  tags = {
    Name = "SimpleAD"
  }
}


#
resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.test.id
  launch_configuration      = aws_launch_configuration.foobar.name
  vpc_zone_identifier       = [aws_subnet.example1.id, aws_subnet.example2.id]

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

