data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.wordpress.id]
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/user_data.sh", {
    mysql_root_password = var.mysql_root_password
    mysql_password      = var.mysql_password
  })

  tags = {
    Name = "${var.project_name}-instance"
  }

}

resource "aws_eip" "wordpress" {
  instance = aws_instance.wordpress.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  depends_on = [aws_internet_gateway.main]

}