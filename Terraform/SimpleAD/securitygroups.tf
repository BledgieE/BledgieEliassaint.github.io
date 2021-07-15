
#Security Group for Bastion EC2
#------------------------------
resource "aws_security_group" "Bastion_EC2" {
  name                    = "Bastion_EC2"
  description             = "Allow TCP RDP inbound traffic to the Bastion host instance from singular ip address"
  vpc_id                  = aws_vpc.Main.id
 
 }
resource "aws_security_group_rule" "Bastion_EC2_inbound_rule" {
  type = "ingress"
    from_port             = 3389
    to_port               = 3389
    protocol              = "tcp"
    security_group_id     = "${aws_security_group.Bastion_EC2.id}"
    cidr_blocks           = [var.ip_address]
}

resource "aws_security_group_rule" "Bastion_EC2_outbound_rule" {
  
    type = "egress"
    from_port             = 3389
    to_port               = 3389
    protocol              = "tcp"
    security_group_id     = "${aws_security_group.Bastion_EC2.id}"
    cidr_blocks           = ["0.0.0.0/0"]
}




#Security Group for Windows EC2
#-------------------------------
resource "aws_security_group" "Windows_EC2" {
  name                     = "Windows_EC2"
  description              = "Allow tcp RDP inbound traffic from internal NLB"
  vpc_id                   = aws_vpc.Main.id
}

 resource "aws_security_group_rule" "Windows_EC2_inbound_rule" {
  type = "ingress"
    from_port                 = 3389
    to_port                   = 3389
    protocol                  = "tcp"
    security_group_id         = "${aws_security_group.Windows_EC2.id}"
    source_security_group_id  = "${aws_security_group.Bastion_EC2.id}"
}

 resource "aws_security_group_rule" "Windows_EC2_outbound_rule" {
  
    type = "egress"
    from_port                  = 3389
    to_port                    = 3389
    protocol                   = "tcp"
    security_group_id          = "${aws_security_group.Windows_EC2.id}"
    cidr_blocks                = ["0.0.0.0/0"]
    }



#Security Group for access to Simple AD
#-------------------------------
resource "aws_security_group" "SimpleAD_Access" {
  name                          = "SimpleAD Access"
  description                   = "Allow Windows Adminstration server to access all traffic from Directory Serivce"
  vpc_id                        = aws_vpc.Main.id
}

resource "aws_security_group_rule" "SimpleAD_Access_inbound_rule" {
  type = "ingress"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    security_group_id            = "${aws_security_group.SimpleAD_Access.id}"
    source_security_group_id     = "${data.aws_directory_service_directory.my_domain_controller.security_group_id}"
}

 resource "aws_security_group_rule" "SimpleAD_Access_outbound_rule" {
  
    type = "egress"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    security_group_id          = "${aws_security_group.Windows_EC2.id}"
    cidr_blocks                = ["0.0.0.0/0"]
    }