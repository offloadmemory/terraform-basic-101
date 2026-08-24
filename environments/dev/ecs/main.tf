# ECS workspace — the app itself: an ECS Fargate service behind an ALB.
#
# Every service component here is a Terraform Registry module — no custom
# code. This workspace reads the network outputs from the network workspace's
# state (same pattern as the database workspace) and creates:
#
#   terraform-aws-modules/ecs/aws//modules/cluster   → the cluster
#   terraform-aws-modules/alb/aws                   → the load balancer
#   terraform-aws-modules/ecs/aws//modules/service  → the running service

# Pull the network outputs (subnet IDs, VPC ID) from the network workspace.
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket       = "terraform-basic-101-tfstate"
    key          = "dev/network/terraform.tfstate"
    region       = "us-east-1"
    profile      = "dev"
    use_lockfile = true
  }
}

# 1. The cluster — a Fargate-ready ECS cluster with its CloudWatch log group.
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 7.6.0"

  name = var.cluster_name

  # Logs from all containers in this cluster land in this log group.
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = var.log_retention_days

  tags = var.tags
}

# 2. The load balancer — sits in the public subnets and forwards HTTP/80
#    to the container. The module creates its own security group allowing
#    HTTP from the internet.
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.5.0"

  name               = var.alb_name
  load_balancer_type = "application"
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids

  # Listen on port 80 and forward to the target group "ecs" (created below).
  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTP from anywhere"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ecs"
      }
    }
  }

  target_groups = {
    ecs = {
      name_prefix = "basic-101-"
      protocol    = "HTTP"
      port        = 80
      target_type = "ip"
      health_check = {
        path = "/"
      }
    }
  }

  tags = var.tags
}

# 3. The service — runs the app container on Fargate inside the private
#    subnets, attached to the ALB's "ecs" target group.
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 7.6.0"

  name        = var.service_name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  # Fargate: the simplest way to run containers on AWS — no servers to manage.
  requires_compatibilities = ["FARGATE"]
  launch_type              = "FARGATE"

  # The container lives in the private subnets and is reached only through
  # the load balancer.
  subnet_ids       = data.terraform_remote_state.network.outputs.private_subnet_ids
  assign_public_ip = false
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id

  # The module creates a security group for the service that only allows
  # traffic from the ALB security group.
  create_security_group = true
  security_group_ingress_rules = {
    alb_to_service = {
      referenced_security_group_id = module.alb.security_group_id
      from_port                    = 80
      to_port                      = 80
    }
  }
  security_group_egress_rules = {
    all_outbound = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Wire the ALB target group to this service.
  load_balancer = {
    ecs = {
      target_group_arn = module.alb.target_groups["ecs"].arn
      container_name   = "app"
      container_port   = 80
    }
  }

  # The container definition — a simple "hello world" image so the demo
  # immediately shows a working URL. The definition uses keys from the
  # AWS ECS task-definition API; this module translates them directly.
  container_definitions = {
    app = {
      name      = "app"
      image     = var.container_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.cloudwatch_log_group_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  }

  tags = var.tags
}
