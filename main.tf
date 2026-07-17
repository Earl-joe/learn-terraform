provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default = 8080
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

output "public_ip" {
    value = aws_instance.my-instance.public_ip
    description = "The public IP address of the web server"
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0"] 
    }
}

resource "aws_launch_configuration" "learn-asg" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "learn-asg" {
    launch_configuration = aws_launch_configuration.learn-asg
    vpc_zone_identifier = data.aws_subnets.default.ids

    min size = 2
    max size = 10

    tag{
        key = "Name"
        value = "terraform-asg-learnasg
        propagate_at_launch = true
    }
}

resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn 
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }

    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
}






 

