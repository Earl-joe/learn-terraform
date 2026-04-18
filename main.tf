provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "my-instance" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t3.micro"

    tags = {
        Name = "terraform-example"
    }
}