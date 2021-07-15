# launch template for auto scaling group
#-----------------------------------------------------------
resource "aws_launch_configuration" "Windows_Admin" {
  name_prefix                   = "Windows"
  image_id                      = "ami-077f1edd46ddb3129"
  instance_type                 = "t2.micro"
  key_name                      = "WindowsAdministration"
  associate_public_ip_address   = false
  security_groups               = [aws_security_group.Windows_EC2.id,aws_security_group.SimpleAD_Access.id]
}


#Create auto scaling group for windows admin servers 
#-----------------------------------------------------------
resource "aws_autoscaling_group" "WindowsAdmin_ASG" {
  name                          = "WindowsAdmin_ASG"
  max_size                      = 3
  min_size                      = 1
  health_check_grace_period     = 300
  health_check_type             = "ELB"
  desired_capacity              = 1
  force_delete                  = true
  launch_configuration          = aws_launch_configuration.Windows_Admin.id
  vpc_zone_identifier           = [aws_subnet.Main_Pub_1.id, aws_subnet.Main_Pub_2.id]
  wait_for_capacity_timeout     = "0m"

  initial_lifecycle_hook {
    name                        = "foobar"
    default_result              = "CONTINUE"
    heartbeat_timeout           = 2000
    lifecycle_transition        = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  timeouts {
    delete                      = "15m"
  }

  tag {
    key                         = "Name"
    value                       = "Windows-Admin"
     propagate_at_launch        = true
  }

}


# Create an SSM Document to join AD Domain
# ----------------------------------------
data "aws_directory_service_directory" "my_domain_controller" {
  directory_id = aws_directory_service_directory.SimpleAD.id
}

resource "aws_ssm_document" "ad-join-domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion"         = "2.2"
      "description"           = "aws:domainJoin"
      "mainSteps"             = [
        {
          "action"            = "aws:domainJoin",
          "name"              = "domainJoin",
          "inputs"            = {
            "directoryId"     : data.aws_directory_service_directory.my_domain_controller.id,
            "directoryName"   : data.aws_directory_service_directory.my_domain_controller.name
            "dnsIpAddresses"  : sort(data.aws_directory_service_directory.my_domain_controller.dns_ip_addresses)
          }
        }
      ]
    }
  )
	depends_on = [aws_directory_service_directory.SimpleAD]
}


# Join Windows Management server to domain
# -----------------------------------------
resource "aws_ssm_association" "windows_server_association" {
  name = aws_ssm_document.ad-join-domain.name
  targets {
    key    = "tag:Name"
    values = ["Windows-Admin"]
  }
}
