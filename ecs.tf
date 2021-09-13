
locals {
  name        = "tztf-ecs"
  environment = "test"

  ec2_resources_name = "${local.name}-${local.environment}"
}


data "aws_availability_zones" "available" {
  state = "available"
}


# ECS 
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.4.0"



  name               = "tztf-ecs"
  container_insights = "false"

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [{
    capacity_provider = aws_ecs_capacity_provider.prov1.name # "FARGATE_SPOT"
    weight            = "1"
  }]

  tags = {
    Environment = local.environment
  }
}



module "ecs_ecs-instance-profile" {
  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  version = "3.4.0"

  name = local.name

  tags = {
    Environment = local.environment
  }
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }

}

# ECS  Services
resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "tztf"
      image     = "docker.io/clayd13/tztfprivate:v3"
      cpu       = 250
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}




# ECS  Resources

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = local.ec2_resources_name

  # Launch configuration
  lc_name   = local.ec2_resources_name
  use_lc    = true
  create_lc = true

  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t2.micro"
  security_groups           = [module.security-group_http-80.security_group_id, module.ssh_security_group.security_group_id]
  iam_instance_profile_name = module.ecs_ecs-instance-profile.iam_instance_profile_id
  user_data                 = file("script/user-data.sh")
  key_name                  = module.key_pair.key_pair_key_name

  # Auto scaling group
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
    {
      key                 = "Your_First_Name"
      value               = var.your_first_name
      propagate_at_launch = true
    },
    {
      key                 = "Your_Last_Name"
      value               = var.your_last_name
      propagate_at_launch = true
    },
    {
      key                 = "AWS_Account_ID"
      value               = data.aws_caller_identity.current.account_id
      propagate_at_launch = true
    },
    {
      key                 = "OS_type"
      value               = "Amazon Linux 2"
      propagate_at_launch = true
    },
    {
      key                 = "Instance_type"
      value               = var.instance_type
      propagate_at_launch = true
    },
    {
      key                 = "Region"
      value               = var.region_name
      propagate_at_launch = true
    }
  ]
}

