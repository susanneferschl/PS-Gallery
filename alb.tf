# Create an Application Load Balancer
resource "aws_lb" "gallery_alb" {
  name               = "gallery-alb"
  internal           = false # Set to true if the ALB should be internal
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Specify your public subnet(s) here
  security_groups    = [aws_security_group.gallery_sg.id]

  enable_deletion_protection = false # Set to true to prevent accidental deletion

  tags = {
    Name = "gallery-alb"
  }
}

#create listener for port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.gallery_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gallery-target-group.arn
  }
}


# Create the target group
resource "aws_lb_target_group" "gallery-target-group" {
  name        = "gallery-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev_vpc.id
  target_type = "instance"

  # Add tags
  tags = {
    Name = "gallery-target-group"
  }
}

# Create the target group attachment
resource "aws_lb_target_group_attachment" "gallery_target_group_attachment" {
  target_group_arn = aws_lb_target_group.gallery-target-group.arn
  
  target_id        = aws_instance.gallery_instance.id
  port             = 80
}

# Attach the ALB to the Auto Scaling Group
resource "aws_autoscaling_attachment" "gallery_auto_alb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.gallery_autoscaling_group.id
  lb_target_group_arn   = aws_lb_target_group.gallery-target-group.arn
  
}