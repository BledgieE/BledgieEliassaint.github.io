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


# Create subnets (2 private and 2 public)
resource "aws_subnet" "Main_Pub_1" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.1.0/24"
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
        Access = "Private"
    }
}

resource "aws_subnet" "Main_Pub_2" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true

    tags = {
        Access = "Public"
    }
}

resource "aws_subnet" "Main_Priv_2" {
    vpc_id = aws_vpc.Main.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1d"
    map_public_ip_on_launch = false

    tags = {
        Access = "Private"
    }
}

#Create Internent Gateway
resource "aws_internet_gateway" "Main_IG" {
  vpc_id = aws_vpc.Main.id
  tags = {
    "Name" = "Main_Internet_Gateway"
  }
}

#Allocate Elastic IP for NAT Gateway 
resource "aws_eip" "NAT-eip" {
   vpc      = true  
   depends_on = [aws_internet_gateway.Main_IG
   
     
   ]
}

#Allocate Elastic IP for 2nd NAT Gateway 
resource "aws_eip" "NAT-2-eip" {
   vpc      = true
   depends_on = [aws_internet_gateway.Main_IG
     
   ]
}

#Create NAT Gateway
resource "aws_nat_gateway" "Public-NAT" {
  allocation_id = aws_eip.NAT-eip.id
  subnet_id     = aws_subnet.Main_Pub_1.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.Main_IG]
}



  #Create 2nd NAT Gateway
resource "aws_nat_gateway" "Public-NAT-2" {
  allocation_id = aws_eip.NAT-2-eip.id
  subnet_id     = aws_subnet.Main_Pub_2.id

  tags = {
    Name = "gw NAT-2"
  }

  depends_on = [aws_internet_gateway.Main_IG]
}


#Create Public Route Table 
resource "aws_main_route_table_association" "main"{
    vpc_id = aws_vpc.Main.id
    route_table_id = aws_route_table.Public_Routes.id
}

resource "aws_route_table" "Public_Routes" {
  vpc_id = aws_vpc.Main.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.Main_IG.id
  }
}

#Create Private Route Table 
resource "aws_route_table" "Private_Routes" {
    depends_on = [
      aws_nat_gateway.Public-NAT
    ]
  vpc_id = aws_vpc.Main.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.Public-NAT.id
      
  }
}

#Create 2nd Private Route Tables
resource "aws_route_table" "Private_Routes_2" {
    depends_on = [
      aws_nat_gateway.Public-NAT-2
    ]
  vpc_id = aws_vpc.Main.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.Public-NAT-2.id
      
  }
}



#Create Public Route Table 
resource "aws_route_table_association" "Public_Subnet-1-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Pub_1.id
  route_table_id = aws_route_table.Public_Routes.id
}

resource "aws_route_table_association" "Public_Subnet-2-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Pub_2.id
  route_table_id = aws_route_table.Public_Routes.id
}

#Create Private Route Table for 1st NAT
resource "aws_route_table_association" "Private_Subnet-1-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Priv_1.id
  route_table_id = aws_route_table.Private_Routes.id
}

#Create Private Route Table for 2nd NAT
resource "aws_route_table_association" "Private_Subnet-2-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Priv_2.id
  route_table_id = aws_route_table.Private_Routes_2.id
}

