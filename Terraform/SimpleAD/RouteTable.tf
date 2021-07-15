#Create Public Route Table 
resource "aws_route_table" "Public_Routes" {
  vpc_id                    = aws_vpc.Main.id
  route {
      cidr_block            = "0.0.0.0/0"
      gateway_id            = aws_internet_gateway.Main_IG.id
  }
}

#Create Public Route Association  
resource "aws_route_table_association" "Public_Subnet-1-Route_Assocaition" {
  subnet_id                 = aws_subnet.Main_Pub_1.id
  route_table_id            = aws_route_table.Public_Routes.id
}

resource "aws_route_table_association" "Public_Subnet-2-Route_Assocaition" {
  subnet_id                 = aws_subnet.Main_Pub_2.id
  route_table_id            = aws_route_table.Public_Routes.id
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

#Create Private Route Table for NAT
resource "aws_route_table_association" "Private_Subnet-1-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Priv_1.id
  route_table_id = aws_route_table.Private_Routes.id
}

resource "aws_route_table_association" "Private_Subnet-2-Route_Assocaition" {
  subnet_id = aws_subnet.Main_Priv_2.id
  route_table_id = aws_route_table.Private_Routes.id
}