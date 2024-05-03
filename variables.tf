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

ecs variables
--------------------------------

variable "ecscluster-name" {
	type = "string"
}

variable "ecs-family" {
	type = "string"
}

variable "networkmode" {
	type = "string"
}

variable "region" {
	type = "string"
}

variable "cpu" {
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = null

}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = null
}

variable "execution_role_arn" {
  description = "Allows to override the default execution role used by the task. Use in combination with `create_execution_role`."
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "Allows to override the default Task role used by the task. Use in combination with `create_task_role`."
  type        = string
  default     = null
}

variable "ecs_subnets" {
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
