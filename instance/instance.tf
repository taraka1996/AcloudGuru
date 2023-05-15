provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Create public and private subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "example-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "example-private-subnet"
  }
}

# Create a security group for the instances
resource "aws_security_group" "example" {
  name_prefix = "example"
  vpc_id      = aws_vpc.example.id

  # Allow SSH access from the public IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from the load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances in the public and private subnets
resource "aws_instance" "public" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.example.id,
  ]

  tags = {
    Name = "example-public-instance"
  }
}

resource "aws_instance" "private" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [
    aws_security_group.example.id,
  ]

  tags = {
    Name = "example-private-instance"
  }
}

# Create a load balancer to distribute traffic to the instances
resource "aws_security_group" "lb" {
  name_prefix = "example-lb"
  vpc_id      = aws_vpc.example.id

  # Allow HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  subnet_mapping {
    subnet_id = aws_subnet.example-subnet.id

  }
} 