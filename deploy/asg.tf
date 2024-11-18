data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_key_pair" "main" {
  count = var.public_key != null ? 1 : 0
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7BOwtNlTJZ+wywqNFoaOsoxxWNyxzeo78kRq3Q/QUD"
}

resource "aws_launch_template" "main" {
  name                   = provider::slugify::slug("${local.application_name}-${var.environment}")
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.al2.value
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = length(aws_key_pair.main) > 0 ? aws_key_pair.main[0].key_name : null

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.instance_block_size
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_node.arn
  }

  user_data = base64encode(<<-EOT
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
    EOT
  )
}


resource "aws_autoscaling_group" "main" {
  name                      = provider::slugify::slug("${local.application_name}-${var.environment}")
  vpc_zone_identifier       = aws_subnet.main_private[*].id
  min_size                  = 0
  max_size                  = var.asg_max_size
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = provider::slugify::slug("${local.application_name}-${var.environment}")
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
