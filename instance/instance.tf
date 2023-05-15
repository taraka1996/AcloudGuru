provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0b5a2b5b8f2be4ec2"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
