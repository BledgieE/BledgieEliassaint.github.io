#aws instance 
#------------------------------------------------
resource "aws_instance" "Bastion_host" {
    ami                             = "ami-077f1edd46ddb3129"
    instance_type                   = "t2.micro"
    associate_public_ip_address     = true
    key_name                        = "WindowsAdministration"
    security_groups                 = [aws_security_group.Bastion_EC2.id]
    subnet_id                       = aws_subnet.Main_Pub_1.id
}