variable "ENV" {
  type    = string
  default = "test"
}

variable "RES" {
  type    = string
  default = "net"
}

variable "VPC" {
  type    = string
  default = "raw_tf_prod_vpc"
}


variable "REGION" {
  type    = string
  default = "eu-west-3"
}

variable "VPC_CIDR" {
  type    = string
  default = "10.1.0.0/16"
}

variable "SUBNET_CIDR" {
  type    = list(any)
  default = ["10.1.1.0/24"]
}

variable "APP" {
  type    = string
  default = "web-app"
}

variable "TEAM" {
  type    = string
  default = "devops"
}

variable "CREATED" {
  type    = string
  default = "by Terraform"
}

variable "OWNER" {
  type    = string
  default = "Ravil Nagmetov"
}

variable "COST" {
  type    = string
  default = "COST center"
}

variable "use_public_ip" { 
  default = "true" 
}