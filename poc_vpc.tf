terraform
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = var.nat_name
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "public_route_tbl" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_tbl.id
}

resource "aws_security_group" "outbound" {
  provider    = aws.account
  name        = "Outbound"
  description = "AWS Outbound"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags =
    {
      Name = "Outbound"
    }

  lifecycle {
    ignore_changes = [
      description,
      ingress,
      egress,
    ]
  }
}

resource "aws_security_group" "service" {
  provider    = aws.account
  name        = "Service"
  description = "AWS Service"
  vpc_id      = local.vpc_id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 53
    to_port          = 53
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  tags ={
      Name = "Service"
  }

  lifecycle {
    ignore_changes = [
      description,
      ingress,
      egress,
    ]
  }
}

Peering
-------------------------------
resource "aws_vpc_peering_connection" "peer" {
  provider            = "aws.vpc2"
  vpc_id              = aws_vpc.vpc1.id
  peer_vpc_id         = aws_vpc.vpc2.id
  peer_region         = var.peer_region
  auto_accept         = true
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.public_route_tbl.id
  destination_cidr_block = aws_subnet.public_subnet.cidr_block
  gateway_id             = aws_vpc_peering_connection.peer.id
}

rds
-----------------
terraform
provider "aws" {
  region = "us-west-2"
}

resource "aws_db_subnet_group" "example" {
  name       = var.db_subnet_group "my-db-subnet-group"
  subnet_ids = var.subnet_ids["subnet-12345678", "subnet-23456789"]  # Add your subnet IDs here
}

resource "aws_rds_cluster" "example" {
  cluster_identifier      = var.cluster_identifier "my-db-cluster"
  engine                  = var.engine "aurora"
  engine_version          = var.engine_version "5.6.10a"
  master_username         = var.username"admin"
  master_password         = random_string.password.result
  db_subnet_group_name    = aws_db_subnet_group.example.name
  iam_roles               = var.rdsiamroles
  skip_final_snapshot     = true
  vpc_security_group_ids  = var.vpcsecgrp
}

resource "aws_rds_cluster_instance" "example" {
  cluster_identifier = aws_rds_cluster.example.id
  instance_class     = "db.r5.large"
  engine             = var.engine "aurora"
}

output "db_cluster_endpoint" {
  value = aws_rds_cluster.example.endpoint
}

output "db_instance_endpoint" {
  value = aws_rds_cluster_instance.example.endpoint
}



resource "random_string" "password" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()"
}

resource "aws_secretsmanager_secret" "my_secret" {
  name         = var.secret_name
  description  = var.secret_description
}

resource "aws_secretsmanager_secret_version" "my_secret_value" {
  secret_id     = aws_secretsmanager_secret.my_secret.id
  secret_string = random_string.password.result
}


data "aws_secretsmanager_secret_version" "my_secret_value" {
  secret_id = aws_secretsmanager_secret.my_secret.id
}

output "my_secret_value" {
  value = data.aws_secretsmanager_secret_version.my_secret_value.secret_string
}

ecs
---------------------------

terraform
provider "aws" {
  region = "us-west-2"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = var.ecscluster-name "my-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family                = var.ecs-family "my-task"
  network_mode          = var.networkmode"awsvpc"
  cpu                   = var.cpu 256
  memory                = var.memory 512
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "my-container-image"
      cpu       = 256
      memory    = 512
    }
  ])
}

resource "aws_ecs_service" "my_service" {
  name            = var.ecsservice-name"my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"
  
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  network_configuration {
    subnets         = var.ecs_subnets["subnet-abc123", "subnet-def456"]
    assign_public_ip = "ENABLED"
    security_groups = var.ecs_sg["sg-123456"]
  }

  depends_on = [
    aws_ecs_cluster.my_cluster,
    aws_ecs_task_definition.my_task,
  ]
}
