data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.1.20230705.0-kernel-6.1-x86_64"]
  }

  owners = ["amazon"]
}

#Use this to get the vpc id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["sandbox-vpc"]
  }
}

#Use this to get the subnet IDs within the above vpc
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

resource "aws_instance" "docker" {
  ami                         = data.aws_ami.al2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = flatten(data.aws_subnets.public.ids)[0]
  security_groups             = ["sg-01adb0fa94b766534"]
  user_data                   = <<EOF
#!/bin/bash
sudo su
yum install git -y
yum install docker -y
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl start docker
EOF
tags = {
    Name = "enchen-docker-terraform"   #Change the value of this
  }
}