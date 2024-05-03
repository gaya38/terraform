variable "vpc_name" {
	type = string
}
variable "vpc_cidr" {
	type = string
}
variable "public_subnet_name" {
	type = string
}
variable "public_subnet_cidr" {
	type = string
}
variable "private_subnet_name" {
	type = string
}
variable "private_subnet_cidr" {
	type = string
}
variable "igw_name" {
	type = string
}
variable "nat_name" {
	type = string
}
variable "igw_cidr" {
	type = string
}
variable "region" {
	type = "string"
}

rds variables
----------------------------------
variable "db_subnet_group" {
	type = "string"
}

variable "region" {
	type = "string"
}
variable "subnet_ids" {
	type = "list"
}
variable "rdsiamroles" {
  description = "iam roles for rds to interact with other aws resources. default set null."
  default     = []
}
variable "vpcsecgrp" {
  description = "list of VPC security groups to associate"
  type        = list
}
