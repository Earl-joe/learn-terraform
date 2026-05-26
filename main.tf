provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default = 8080
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

resource "aws_instance" "my-instance" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    
    user_data_replace_on_change = true
                
    tags = {
        Name = "terraform-example"
    }

}

 

