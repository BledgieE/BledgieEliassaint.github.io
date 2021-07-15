#Create SimpleAD 
#---------------
resource "aws_directory_service_directory" "SimpleAD" {
  name                   = var.ad_name
  password               = var.ad_password
  size                   = "Small"


  vpc_settings {
    vpc_id               = aws_vpc.Main.id
    subnet_ids           = [aws_subnet.Main_Priv_1.id, aws_subnet.Main_Priv_2.id]
  }

  tags = {
    Name = "SimpleAD"
  }
}
