variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project_name" {
  type    = string
  default = "wordpress-ec2"
}

variable "my_ip" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "mysql_root_password" {
  type      = string
  sensitive = true
}