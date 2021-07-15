provider "aws" {

region                    = "us-east-1"
shared_credentials_file   = "~/.aws/credentials"
}

variable "ad_name" {
  type                    = string
  description             = "AD server name"
  sensitive               = true 
  
}

variable "ad_password" {
    type                  = string
    description           = "AD server name password"
    sensitive             = true 
  
}


variable "ip_address" {
    type                  = string
    description           = "ip address to access security group"  
    sensitive             = true
}