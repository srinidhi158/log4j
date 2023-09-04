# Set the provider to AWS
provider "aws" {
  region = "us-west-2" # Change this to your desired region
}

# Global random variable
resource "random_string" "globalrandom1" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

# Filter the RHEL-7* ami
data "aws_ami" "most_recent_amazon_linux_2" {
  owners = [
    "amazon",
  ]

  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-2.0.??????????-x86_64-gp2",
    ]
  }

  filter {
    name = "state"

    values = [
      "available",
    ]
  }
}

# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name      = "UC19-vpc"
    yor_name  = "example_vpc"
    yor_trace = "8027b4b2-e8ef-4f01-980d-3b8c689df3aa"
  }
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    yor_name  = "example_igw"
    yor_trace = "4ce105aa-d153-4c05-b729-4d186fc22f18"
  }
}

# Create public subnets (You can add more subnets as needed)
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name      = "UC19-public subnet"
    yor_name  = "public_subnet_1"
    yor_trace = "c16bb2fe-2938-497a-b0eb-e69049c12482"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    yor_name  = "public_subnet_2"
    yor_trace = "2f3b4201-69bd-4477-84f1-0657dc2795f7"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    yor_name  = "public_subnet_route_table"
    yor_trace = "3763965e-078f-46de-bd23-7cb2fe72a029"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# Create security group for load balancer
resource "aws_security_group" "lb_sg" {
  name_prefix = "uc19_lb_sg_"
  vpc_id      = aws_vpc.example_vpc.id

  # In a real-world scenario, we should lock down these security group rules to specific ports and IP ranges.
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    yor_name  = "lb_sg"
    yor_trace = "f96acb7c-f992-43f0-8406-e31cac219e7b"
  }
}

# Create security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name_prefix = "uc19-instance-sg_"
  vpc_id      = aws_vpc.example_vpc.id

  # In a real-world scenario, you should lock down these security group rules to specific ports and IP ranges.
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    yor_name  = "instance_sg"
    yor_trace = "ce1fce29-4759-4c10-abe9-2a80a5b72132"
  }
}

# Create Application Load Balancer
resource "aws_lb" "example_alb" {
  name            = "uc19-test-alb"
  internal        = false
  security_groups = [aws_security_group.lb_sg.id]
  subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] # Add more subnets if multiple AZs
  tags = {
    yor_name  = "example_alb"
    yor_trace = "1d78dbc3-7b71-4a98-94a7-f5f122b36179"
  }
}

# Fetch AWS account ID using data source
data "aws_caller_identity" "current" {}

# Public key file location
variable "aws_key_file_pub_location" {
  type    = string
  default = "key_pair.pub"
}

# Create a key pair
resource "aws_key_pair" "darwin-instance-key" {
  key_name   = "systest-darwin-${random_string.globalrandom1.result}"
  public_key = file(var.aws_key_file_pub_location)

  tags = {
    dnd_automation = "true"
    purpose        = "tenable_test"
    createdby      = "automation"
    Name           = "systest-tenable"
    yor_name       = "darwin-instance-key"
    yor_trace      = "bcd39caa-379e-4a42-b14c-42a35ba65555"
  }
}

# Create EC2 instance
resource "aws_instance" "example_instance" {
  ami                         = data.aws_ami.most_recent_amazon_linux_2.id # Redhat, you can change this based on your region
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.darwin-instance-key.key_name # Replace with the name of your EC2 key pair
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]

  tags = {
    Name      = "system-test-log4j-vuln"
    yor_name  = "example_instance"
    yor_trace = "41dd58b5-d46b-451f-94f9-7b023e3c0f0e"
  }

  # You can add more user data scripts as needed, this installs Docker
  user_data = <<-EOF
              #!/bin/bash
              yum -y update
              yum -y install docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              EOF
}

# Output the ALB URL and EC2 public IP for convenience
output "alb_dns_name" {
  value = aws_lb.example_alb.dns_name
}

output "ec2_public_ip" {
  value = aws_instance.example_instance.public_ip
}

output "ec2_instance_name" {
  value = aws_instance.example_instance.tags.Name
}
