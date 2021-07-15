#Create intial vpc
#------------------
resource "aws_vpc" "Main" {
  cidr_block                 = "10.0.0.0/16"
  tags = {
    Name = "Main-vpc"
  }
}

#Create Internent Gateway
#-------------------------
resource "aws_internet_gateway" "Main_IG" {
  vpc_id                      = aws_vpc.Main.id
  tags = {
    "Name"                    = "Main_Internet_Gateway"
  }
}

#Allocate Elastic IP for NAT Gateway
#-----------------------------------
resource "aws_eip" "NAT-eip" {
   vpc                        = true  
   depends_on                 = [aws_internet_gateway.Main_IG 
   ]
}


#Create NAT Gateway
#------------------
resource "aws_nat_gateway" "Public-NAT" {
  allocation_id                = aws_eip.NAT-eip.id
  subnet_id                    = aws_subnet.Main_Pub_1.id

  tags = {
    Name = "gw NAT"
  }
}

# Create Public subnets
#-----------------------
resource "aws_subnet" "Main_Pub_1" {
    vpc_id                     = aws_vpc.Main.id
    cidr_block                 = "10.0.1.0/24"
    availability_zone          = "us-east-1d"
    map_public_ip_on_launch    = true

    tags = {
        Access = "Public"
    }
}

resource "aws_subnet" "Main_Pub_2" {
    vpc_id                      = aws_vpc.Main.id
    cidr_block                  = "10.0.3.0/24"
    availability_zone           = "us-east-1b"
    map_public_ip_on_launch     = true

    tags = {
        Access = "Public"
    }
}

#Create Private subnets
#-----------------------
resource "aws_subnet" "Main_Priv_1" {
    vpc_id                      = aws_vpc.Main.id
    cidr_block                  = "10.0.2.0/24"
    availability_zone           = "us-east-1a"
    map_public_ip_on_launch     = false

    tags = {
        Name = "Private_Subnet"
    }
}

resource "aws_subnet" "Main_Priv_2" {
    vpc_id                      = aws_vpc.Main.id
    cidr_block                  = "10.0.4.0/24"
    availability_zone           = "us-east-1c"
    map_public_ip_on_launch     = false

    tags = {
        Name = "Private_Subnet_2"
    }
}

