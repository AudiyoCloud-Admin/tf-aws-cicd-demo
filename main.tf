data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_security_group" "web" {
  name        = "${var.project}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name                    = "tf-demo-key"   # Key Pair

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              echo "Hello from Terraform on $(hostname)" > /usr/share/nginx/html/index.html
              systemctl start nginx
              EOF

  tags = {
    Name = "${var.project}-ec2"
    Environment = "Demo"   # <-- new tag
  }
}

resource "aws_s3_bucket" "demo" {
  count  = var.create_bucket ? 1 : 0
  bucket = "${var.project}-${random_id.suffix.hex}"
  tags = {
    Name = "${var.project}-bucket"
  }
}

resource "aws_s3_bucket_versioning" "demo_ver" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.demo[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
