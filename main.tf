provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0"] 
    }
}

resource "aws_instance" "my-instance" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    
    user_data_replace_on_change = true
                
    tags = {
        Name = "terraform-example"
    }
}