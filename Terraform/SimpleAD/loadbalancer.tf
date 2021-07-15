#internal laod balancer for windows admin servers 
#------------------------------------------------
resource "aws_lb" "windows" {
  name                           = "windows-admin-lb"
  internal                       = true
  load_balancer_type             = "network"
  subnets                        = [aws_subnet.Main_Pub_1.id, aws_subnet.Main_Pub_2.id]

  tags = {
    Name = "Admin ELB"
  }
}

#load balancer target group
#------------------------------------------------
resource "aws_lb_target_group" "windows-tg" {
  name                          = "windows-tg"
  port                          = 3389
  protocol                      = "TCP"
  vpc_id                        = aws_vpc.Main.id
  target_type                   = "instance"

}

#load balancer attachment 
#--------------------------------------------------------------------------
resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name        = aws_autoscaling_group.WindowsAdmin_ASG.id
  alb_target_group_arn          = aws_lb_target_group.windows-tg.arn
}


#load balancer listeners 
#------------------------------------------------
resource "aws_lb_listener" "windows_server" {
  load_balancer_arn = aws_lb.windows.arn
  port                          = "3389"
  protocol                      = "TCP"

  default_action {
    type                        = "forward"
    target_group_arn            = aws_lb_target_group.windows-tg.arn
  }
}