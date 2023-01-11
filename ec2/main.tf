provider "aws" {
  region = var.REGION
  profile = "DEV"
  default_tags {
    tags = {
      "Env"        = var.ENV
      "Team"       = var.TEAM
      "Managet By" = var.CREATED
      "Owner"      = var.OWNER
      "CostCenter" = "${var.ENV} ${var.COST}"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "raw-tf-state-backend"
    key    = "test2/ec2/terraform.tfstate"
    region = "eu-west-3"
    encrypt        = true
    profile        = "DEV"
  }
}

#DATA

data "terraform_remote_state" "net" {
  backend = "s3"
  config = {
    bucket = "raw-tf-state-backend"
    key    = "test2/net/terraform.tfstate"
    region = "eu-west-3"
    profile        = "DEV"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "raw-tf-state-backend"
    key    = "test2/sg/terraform.tfstate"
    region = "eu-west-3"
    profile        = "DEV"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }
}

#KEY

resource "tls_private_key" "key" {
  count = var.COUNT_EC2
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  count      = var.COUNT_EC2
  key_name   = "raw_tf_${var.ENV}_${var.APP}_secret_key_${count.index + 1}"
  public_key = tls_private_key.key[count.index].public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  count       = var.COUNT_EC2
  name        = "raw_tf_${var.ENV}_${var.APP}_secret_key_${count.index + 1}"
  description = var.DESCRIPTION
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_secret_key_${count.index + 1}"
  }
}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  count         = var.COUNT_EC2
  secret_id     = element(aws_secretsmanager_secret.secret_key[count.index].id[*], count.index)
  secret_string = tls_private_key.key[count.index].private_key_pem
}


#EC2

resource "aws_instance" "raw_tf_ec2" {
  count                  = var.COUNT_EC2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.INSTANCE_TYPE
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.sg_id]
  user_data              = file("user_data.sh")
  subnet_id              = element(data.terraform_remote_state.net.outputs.public_subnet_ids, count.index)
  #subnet_id              = data.terraform_remote_state.net.outputs.public_subnet_ids[count.index]
  key_name               = element(aws_key_pair.keypair[count.index].key_name[*], count.index)

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_ec2_${count.index + 1}"
  }
}
