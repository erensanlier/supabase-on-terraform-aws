resource "aws_lb" "load_balancer_be9_eec3_a" {

  name               = "SupabaseLoadBalancer630C0AFC"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group_a28_d6_dd7.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_security_group" "load_balancer_security_group_a28_d6_dd7" {
  description = "Automatically created Security Group for ELB SupabaseLoadBalancer630C0AFC"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_security_groupfrom_indirect_peer80_ab4_c6575" {
  description       = "CloudFront"
  from_port         = 80
  security_group_id = aws_security_group.load_balancer_security_group_a28_d6_dd7.id
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloud_front_prefix_list22014_efd.id
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_security_groupto_supabase_kong_service_security_group_b3_c4_ac8_f800011_c84_c57" {
  description                  = "Load balancer to target"
  security_group_id            = aws_security_group.load_balancer_security_group_a28_d6_dd7.id
  from_port                    = 8000
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_security_groupto_supabase_kong_service_security_group_b3_c4_ac8_f8100711401_b1" {
  description                  = "ALB healthcheck"
  security_group_id            = aws_security_group.load_balancer_security_group_a28_d6_dd7.id
  from_port                    = 8100
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  to_port                      = 8100
}

resource "aws_lb_listener" "load_balancer_listener_e1_a099_b9" {
  load_balancer_arn = aws_lb.load_balancer_be9_eec3_a.arn # Reference to the load balancer's ARN
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong_target_group_d0277_b2_a.arn
  }
}

# resource "aws_iam_role" "aws679f53fac002430cb0da5b7982bd2287_service_role_c1_ea0_ff2" {
#   assume_role_policy = jsonencode({
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#     Version = "2012-10-17"
#   })
#   managed_policy_arns = [
#     join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"])
#   ]
#   inline_policy {
#     policy = jsonencode({
#       Statement = [
#         {
#           Action   = "ec2:DescribeManagedPrefixLists"
#           Effect   = "Allow"
#           Resource = "*"
#         }
#       ]
#       Version = "2012-10-17"
#     })
#     name = "CloudFrontPrefixListCustomResourcePolicyB6BABDE5"
#   }
# }

# resource "aws_lambda_function" "aws679f53fac002430cb0da5b7982bd22872_d164_c4_c" {
#   function_name = "supabase-cloud-front-prefix-list"
#   s3_bucket     = "supabase-on-aws-${data.aws_region.current.name}"
#   s3_key        = "stable/17c16a3854838fd3ff4bda08146122a6701f33b9c86ae17f415ad0dc47a97544.zip"
#   handler       = "index.handler"
#   role          = aws_iam_role.aws679f53fac002430cb0da5b7982bd2287_service_role_c1_ea0_ff2.arn
#   runtime       = "nodejs18.x"
#   timeout       = 120
# }

data "aws_ec2_managed_prefix_list" "cloud_front_prefix_list22014_efd" {
  filter {
    name = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
}

resource "aws_cloudfront_cache_policy" "cdn_cache_policy957_d7474" {
  name = join("", [local.stack_name, "-CachePolicy-", data.aws_region.current.name])

  min_ttl     = 0
  max_ttl     = 600
  default_ttl = 1

  comment = "Policy for Supabase API"

  parameters_in_cache_key_and_forwarded_to_origin {
    query_strings_config {
      query_string_behavior = "all"
    }
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "apikey",
          "authorization",
          "host"
        ]
      }
    }
    enable_accept_encoding_brotli = true

    enable_accept_encoding_gzip = true
  }
}

resource "aws_cloudfront_response_headers_policy" "cdn_response_headers_policy36_e4_b823" {
  name    = join("", [local.stack_name, "-ResponseHeadersPolicy-", data.aws_region.current.name])
  comment = "Policy for Supabase API"

  custom_headers_config {
    items {
      header   = "server"
      override = true
      value    = "cloudfront"
    }
  }
}

# resource "aws_cloudfront_response_headers_policy" "cdn_response_headers_policy36_e4_b823" {
#   name = join("", [local.stack_name, "-ResponseHeadersPolicy-", data.aws_region.current.name])
#   cors_config {
#     access_control_allow_methods {
#       items = [
#         "GET",
#         "HEAD",
#         "OPTIONS",
#         "PUT",
#         "PATCH",
#         "POST",
#         "DELETE"
#       ]
#     }
#     access_control_allow_credentials = "cloudfront"
#     access_control_allow_headers {
#       items = [
#         "server"
#       ]
#     }
#     access_control_allow_origins {
#       items = [
#         "*"
#       ]
#     }
#     origin_override = true
#   }
#   comment = "Policy for Supabase API"
# }

resource "aws_cloudfront_distribution" "cdn_distribution149_fa6_c8" {
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  enabled = true
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  origin {
    custom_origin_config {
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
      http_port  = 80
      https_port = 443
    }

    domain_name = aws_lb.load_balancer_be9_eec3_a.dns_name
    origin_id   = "SupabaseCdnDistributionOrigin1C1F18041"

  }
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "PATCH",
      "POST",
      "DELETE"
    ]
    cache_policy_id            = aws_cloudfront_cache_policy.cdn_cache_policy957_d7474.id
    compress                   = true
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cdn_response_headers_policy36_e4_b823.id
    target_origin_id           = "SupabaseCdnDistributionOrigin1C1F18041"
    viewer_protocol_policy     = "redirect-to-https"
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD"
    ]
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress                   = true
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    path_pattern               = "storage/v1/object/public/*"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cdn_response_headers_policy36_e4_b823.id
    target_origin_id           = "SupabaseCdnDistributionOrigin1C1F18041"
    viewer_protocol_policy     = "redirect-to-https"
    cached_methods = [
      "GET",
      "HEAD"
    ]
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 500
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 501
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 502
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 503
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 504
  }
  comment = "Supabase - CDN (Supabase/Cdn/Distribution)"

  http_version    = "http2and3"
  is_ipv6_enabled = true
  web_acl_id      = local.CdnWafDisabledF333CA7D ? null : var.web_acl_arn

  // CF Property(DistributionConfig) = {


  // }
}

resource "aws_sqs_queue" "cdn_cache_manager_queue786_d7_fa2" {}

resource "aws_iam_role" "cdn_cache_manager_api_function_service_role_a4_d8_f8_db" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  managed_policy_arns = [
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"])
  ]
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "sqs:SendMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl"
          ]
          Effect   = "Allow"
          Resource = aws_sqs_queue.cdn_cache_manager_queue786_d7_fa2.arn
        }
      ]
      Version = "2012-10-17"
    })
    name = "CdnCacheManagerApiFunctionServiceRoleDefaultPolicy74947A18"
  }
}

resource "aws_lambda_function" "cdn_cache_manager_api_function8_f3_cc846" {
  function_name = "supabase-cdn-cache-manager-api"
  architectures = [
    "arm64"
  ]
  s3_bucket   = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key      = "stable/8a91672f58486c885aa9527e06ea94ef8dcbadc65b50e3e6eff95ea5f50fb0ae.zip"
  description = "Supabase/Cdn/CacheManager/ApiFunction"
  environment {
    variables = {
      QUEUE_URL                           = aws_sqs_queue.cdn_cache_manager_queue786_d7_fa2.id
      API_KEY                             = "${aws_secretsmanager_secret.cdn_cache_manager_api_key137_d2795.id}:apiKey"
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
  handler = "index.handler"
  layers = [
    join("", ["arn:aws:lambda:", data.aws_region.current.name, ":094274105915:layer:AWSLambdaPowertoolsTypeScript:25"])
  ]
  role    = aws_iam_role.cdn_cache_manager_api_function_service_role_a4_d8_f8_db.arn
  runtime = "nodejs20.x"
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_function_url" "cdn_cache_manager_api_function_function_url37928_fc6" {
  authorization_type = "NONE"
  function_name      = aws_lambda_function.cdn_cache_manager_api_function8_f3_cc846.function_name
}

resource "aws_lambda_permission" "cdn_cache_manager_api_functioninvokefunctionurl25_d0_ab1_e" {
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.cdn_cache_manager_api_function8_f3_cc846.arn
  function_url_auth_type = "NONE"
  principal              = "*"
}

resource "aws_iam_role" "cdn_cache_manager_queue_consumer_service_role273_baafa" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  managed_policy_arns = [
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"])
  ]
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action   = "cloudfront:CreateInvalidation"
          Effect   = "Allow"
          Resource = join("", ["arn:aws:cloudfront::", data.aws_caller_identity.current.account_id, ":distribution/", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.id])
        },
        {
          Action = [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "sqs:ReceiveMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:GetQueueUrl",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ]
          Effect   = "Allow"
          Resource = aws_sqs_queue.cdn_cache_manager_queue786_d7_fa2.arn
        }
      ]
      Version = "2012-10-17"
    })
    name = "CdnCacheManagerQueueConsumerServiceRoleDefaultPolicy2DE8002E"
  }
}

resource "aws_lambda_function" "cdn_cache_manager_queue_consumer_a50_b36_c1" {
  function_name = "supabase-cdn-cache-manager-queue-consumer"
  architectures = [
    "arm64"
  ]
  s3_bucket   = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key      = "stable/703e21783239f1557ffe7219fab4fb09901f0ebdefca6570ebb946dd10f3085b.zip"
  description = "Supabase/Cdn/CacheManager/QueueConsumer"
  environment {
    variables = {
      DISTRIBUTION_ID                     = aws_cloudfront_distribution.cdn_distribution149_fa6_c8.id
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
  handler = "index.handler"
  layers = [
    join("", ["arn:aws:lambda:", data.aws_region.current.name, ":094274105915:layer:AWSLambdaPowertoolsTypeScript:25"])
  ]
  role    = aws_iam_role.cdn_cache_manager_queue_consumer_service_role273_baafa.arn
  runtime = "nodejs20.x"
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_event_source_mapping" "cdn_cache_manager_queue_consumer_sqs_event_source_supabase_cdn_cache_manager_queue31_d5861_e48_e96905" {
  batch_size                         = 100
  event_source_arn                   = aws_sqs_queue.cdn_cache_manager_queue786_d7_fa2.arn
  function_name                      = aws_lambda_function.cdn_cache_manager_queue_consumer_a50_b36_c1.arn
  maximum_batching_window_in_seconds = 5
}

resource "aws_iam_role" "kong_task_def_task_role62_a71_ddf" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "kong_task_def115_e456_d" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "KONG_DNS_ORDER"
          Value = "LAST,A,CNAME"
        },
        {
          Name  = "KONG_PLUGINS"
          Value = "request-transformer,cors,key-auth,acl,basic-auth,opentelemetry"
        },
        {
          Name  = "KONG_NGINX_PROXY_PROXY_BUFFER_SIZE"
          Value = "160k"
        },
        {
          Name  = "KONG_NGINX_PROXY_PROXY_BUFFERS"
          Value = "64 160k"
        },
        {
          Name  = "KONG_STATUS_LISTEN"
          Value = "0.0.0.0:8100"
        },
        {
          Name  = "SUPABASE_AUTH_URL"
          Value = "http://auth.supabase.internal:9999/"
        },
        {
          Name  = "SUPABASE_REST_URL"
          Value = "http://rest.supabase.internal:3000/"
        },
        {
          Name  = "SUPABASE_REALTIME_URL"
          Value = "http://realtime-dev.supabase.internal:4000/socket/"
        },
        {
          Name  = "SUPABASE_STORAGE_URL"
          Value = "http://storage.supabase.internal:5000/"
        },
        {
          Name  = "SUPABASE_META_HOST"
          Value = "http://meta.supabase.internal:8080/"
        }
      ]
      Essential = true
      HealthCheck = {
        Command = [
          "CMD",
          "kong",
          "health"
        ]
        Interval = 5
        Retries  = 3
        Timeout  = 5
      }
      Image = "public.ecr.aws/u3p7q2r8/kong:latest"
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.kong_logs4_bd50491.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 8000
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "SUPABASE_ANON_KEY"
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_anon_key_parameter532_dcc06.name])
        },
        {
          Name      = "SUPABASE_SERVICE_KEY"
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_service_role_key_parameter_b65536_eb.name])
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.kong_task_size93_c195_e9]["cpu"]
  execution_role_arn = aws_iam_role.kong_task_def_execution_role349_e43_dd.arn
  family             = "SupabaseKongTaskDef"
  memory             = local.mappings["TaskSize"][var.kong_task_size93_c195_e9]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.kong_task_def_task_role62_a71_ddf.arn
}

resource "aws_iam_role" "kong_task_def_execution_role349_e43_dd" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.kong_logs4_bd50491.arn}:*"
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_anon_key_parameter532_dcc06.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_service_role_key_parameter_b65536_eb.name])
        }
      ]
      Version = "2012-10-17"
    })
    name = "KongTaskDefExecutionRoleDefaultPolicy99546D68"
  }
}

resource "aws_cloudwatch_log_group" "kong_logs4_bd50491" {
  name              = "/aws/ecs/KongLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "kong_service33127_c91" {
  name    = "kong"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count                     = local.KongServiceEnabled5CB62A18 ? 1 : 0
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 60
  launch_type                       = "FARGATE"

  load_balancer {
    container_name   = "app"
    container_port   = 8000
    target_group_arn = aws_lb_target_group.kong_target_group_d0277_b2_a.id
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.kong_service_security_group_e199_ee6_c.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 8000
    registry_arn   = aws_service_discovery_service.kong_service_cloudmap_service59_ecfe3_a.arn
  }
  task_definition = aws_ecs_task_definition.kong_task_def115_e456_d.arn
}

resource "aws_security_group" "kong_service_security_group_e199_ee6_c" {
  description = "Supabase/Kong/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "kong_service_security_groupfrom_supabase_load_balancer_security_group_addf6_eb880000_f4_ca2_e4" {
  description                  = "Load balancer to target"
  from_port                    = 8000
  referenced_security_group_id = aws_security_group.load_balancer_security_group_a28_d6_dd7.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.kong_service_security_group_e199_ee6_c.id
  to_port                      = 8000
}

resource "aws_vpc_security_group_ingress_rule" "kong_service_security_groupfrom_supabase_load_balancer_security_group_addf6_eb881008_d65_c13_d" {
  description                  = "ALB healthcheck"
  from_port                    = 8100
  referenced_security_group_id = aws_security_group.load_balancer_security_group_a28_d6_dd7.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.kong_service_security_group_e199_ee6_c.id
  to_port                      = 8100
}

resource "aws_service_discovery_service" "kong_service_cloudmap_service59_ecfe3_a" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "kong"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "kong_service_task_count_target5_cd21_eeb" {
  count              = local.KongAutoScalingEnabled41DC2F80 ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.kong_service33127_c91.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "kong_service_scale_on_cpu" {
  count              = local.KongAutoScalingEnabled41DC2F80 ? 1 : 0
  name               = "kong-service-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.kong_service_task_count_target5_cd21_eeb[0].resource_id
  scalable_dimension = aws_appautoscaling_target.kong_service_task_count_target5_cd21_eeb[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.kong_service_task_count_target5_cd21_eeb[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "kong_service_task_count_target_scale_on_cpu_e9_fbe5_e2" {
  count               = local.KongAutoScalingEnabled41DC2F80 ? 1 : 0
  resource_group_name = "SupabaseKongServiceTaskCountTargetScaleOnCpu7C47F3C3"
}

resource "aws_lb_target_group" "kong_target_group_d0277_b2_a" {
  name     = "kong-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    interval            = 5
    path                = "/status"
    timeout             = 2
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
  target_type = "ip"
}

resource "aws_iam_role" "auth_task_def_task_role8_ce224_af" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "auth_task_def5_fb652_ed" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "GOTRUE_API_HOST"
          Value = "0.0.0.0"
        },
        {
          Name  = "GOTRUE_API_PORT"
          Value = "9999"
        },
        {
          Name  = "API_EXTERNAL_URL"
          Value = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name])
        },
        {
          Name  = "GOTRUE_DB_DRIVER"
          Value = "postgres"
        },
        {
          Name  = "GOTRUE_SITE_URL"
          Value = var.site_url
        },
        {
          Name  = "GOTRUE_URI_ALLOW_LIST"
          Value = var.redirect_urls
        },
        {
          Name  = "GOTRUE_DISABLE_SIGNUP"
          Value = var.disable_signup
        },
        {
          Name  = "GOTRUE_JWT_ADMIN_ROLES"
          Value = "service_role"
        },
        {
          Name  = "GOTRUE_JWT_AUD"
          Value = "authenticated"
        },
        {
          Name  = "GOTRUE_JWT_DEFAULT_GROUP_NAME"
          Value = "authenticated"
        },
        {
          Name  = "GOTRUE_JWT_EXP"
          Value = var.jwt_expiry_limit
        },
        {
          Name  = "GOTRUE_EXTERNAL_EMAIL_ENABLED"
          Value = "true"
        },
        {
          Name  = "GOTRUE_MAILER_AUTOCONFIRM"
          Value = "false"
        },
        # {
        #   Name  = "GOTRUE_SMTP_ADMIN_EMAIL"
        #   Value = local.WorkMailEnabled ? aws_cloudformation_stack.smtp_work_mail_nested_stack_work_mail_nested_stack_resource042_ecb25.outputs.SupabaseSmtpWorkMailOrganizationSupabaseBD859A4AEmail : var.email
        # },
        # {
        #   Name  = "GOTRUE_SMTP_HOST"
        #   Value = local.WorkMailEnabled ? join("", ["smtp.mail.", var.ses_region, ".awsapps.com"]) : join("", ["email-smtp.", var.ses_region, ".amazonaws.com"])
        # },
        {
          Name  = "GOTRUE_SMTP_ADMIN_EMAIL"
          Value = var.email
        },
        {
          Name  = "GOTRUE_SMTP_HOST"
          Value = join("", ["email-smtp.", var.ses_region, ".amazonaws.com"])
        },
        {
          Name  = "GOTRUE_SMTP_PORT"
          Value = "465"
        },
        {
          Name  = "GOTRUE_SMTP_SENDER_NAME"
          Value = var.sender_name
        },
        {
          Name  = "GOTRUE_MAILER_URLPATHS_INVITE"
          Value = "/auth/v1/verify"
        },
        {
          Name  = "GOTRUE_MAILER_URLPATHS_CONFIRMATION"
          Value = "/auth/v1/verify"
        },
        {
          Name  = "GOTRUE_MAILER_URLPATHS_RECOVERY"
          Value = "/auth/v1/verify"
        },
        {
          Name  = "GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE"
          Value = "/auth/v1/verify"
        },
        {
          Name  = "GOTRUE_EXTERNAL_PHONE_ENABLED"
          Value = "false"
        },
        {
          Name  = "GOTRUE_SMS_AUTOCONFIRM"
          Value = "true"
        },
        {
          Name  = "GOTRUE_RATE_LIMIT_EMAIL_SENT"
          Value = "3600"
        },
        {
          Name  = "GOTRUE_PASSWORD_MIN_LENGTH"
          Value = var.password_min_length
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "PROVIDER1", "_ENABLED"])
          Value = local.AuthProvider1Enabled983DA6B5 ? "true" : "false"
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "PROVIDER1", "_REDIRECT_URI"])
          Value = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name, "/auth/v1/callback"])
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "PROVIDER2", "_ENABLED"])
          Value = local.AuthProvider2Enabled05B8862B ? "true" : "false"
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "PROVIDER2", "_REDIRECT_URI"])
          Value = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name, "/auth/v1/callback"])
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "PROVIDER3", "_ENABLED"])
          Value = local.AuthProvider3Enabled464D1673 ? "true" : "false"
        },
        {
          Name  = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "PROVIDER3", "_REDIRECT_URI"])
          Value = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name, "/auth/v1/callback"])
        }
      ]
      Essential = true
      HealthCheck = {
        Command = [
          "CMD",
          "wget",
          "--no-verbose",
          "--tries=1",
          "--spider",
          "http://localhost:9999/health"
        ]
        Interval = 5
        Retries  = 3
        Timeout  = 5
      }
      Image = var.auth_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.auth_logs940_c0551.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 9999
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "GOTRUE_DB_DATABASE_URL"
          ValueFrom = "${aws_secretsmanager_secret.databasesupabaseauthadmin_f9154_f88.id}:uri::"
        },
        {
          Name      = "GOTRUE_JWT_SECRET"
          ValueFrom = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Name      = "GOTRUE_SMTP_USER"
          ValueFrom = "${aws_secretsmanager_secret.smtp_secret_f89_cc16_b.id}:username::"
        },
        {
          Name      = "GOTRUE_SMTP_PASS"
          ValueFrom = "${aws_secretsmanager_secret.smtp_secret_f89_cc16_b.id}:password::"
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "PROVIDER1", "_CLIENT_ID"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider1_client_id_parameter_a8_cdd11_d.name])
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "PROVIDER1", "_SECRET"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider1_secret_parameter32101_b7_a.name])
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "PROVIDER2", "_CLIENT_ID"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider2_client_id_parameter30_d2_a6_d6.name])
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "PROVIDER2", "_SECRET"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider2_secret_parameter4_b28_a4_be.name])
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "PROVIDER3", "_CLIENT_ID"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider3_client_id_parameter6_da38073.name])
        },
        {
          Name      = join("", ["GOTRUE_EXTERNAL_", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "PROVIDER3", "_SECRET"])
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider3_secret_parameter7_a77_f7_f4.name])
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.auth_task_size9895_c206]["cpu"]
  execution_role_arn = aws_iam_role.auth_task_def_execution_role071231_b5.arn
  family             = "SupabaseAuthTaskDef"
  memory             = local.mappings["TaskSize"][var.auth_task_size9895_c206]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.auth_task_def_task_role8_ce224_af.arn

  depends_on = [aws_lambda_invocation.database_user_password_function_8_eb9_c]
  lifecycle {
    replace_triggered_by = [ aws_lambda_invocation.database_user_password_function_8_eb9_c ]
  }
}

resource "aws_iam_role" "auth_task_def_execution_role071231_b5" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.auth_logs940_c0551.arn}:*"
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.databasesupabaseauthadmin_f9154_f88.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.smtp_secret_f89_cc16_b.id
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider1_client_id_parameter_a8_cdd11_d.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider1_secret_parameter32101_b7_a.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider2_client_id_parameter30_d2_a6_d6.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider2_secret_parameter4_b28_a4_be.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider3_client_id_parameter6_da38073.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.auth_provider3_secret_parameter7_a77_f7_f4.name])
        }
      ]
      Version = "2012-10-17"
    })
    name = "AuthTaskDefExecutionRoleDefaultPolicyB7AFF08D"
  }
}

resource "aws_cloudwatch_log_group" "auth_logs940_c0551" {
  name              = "/aws/ecs/AuthLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "auth_service_ba690728" {
  name    = "auth"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn


  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.AuthServiceEnabled3234D87F ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.auth_service_security_group6440464_f.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 9999
    registry_arn   = aws_service_discovery_service.auth_service_cloudmap_service57_d92_a65.arn
  }
  task_definition = aws_ecs_task_definition.auth_task_def5_fb652_ed.arn
}

resource "aws_security_group" "auth_service_security_group6440464_f" {
  description = "Supabase/Auth/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "auth_service_security_groupfrom_supabase_kong_service_security_group_b3_c4_ac8_f99999367_c437" {
  description                  = "from SupabaseKongServiceSecurityGroupB3C4AC8F:9999"
  from_port                    = 9999
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.auth_service_security_group6440464_f.id
  to_port                      = 9999
}

resource "aws_service_discovery_service" "auth_service_cloudmap_service57_d92_a65" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "auth"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "auth_service_task_count_target07_a8_ccd2" {
  count              = local.AuthAutoScalingEnabled0CD7354E ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.auth_service_ba690728.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "auth_service_scale_on_cpu" {
  count              = local.AuthAutoScalingEnabled0CD7354E ? 1 : 0
  name               = "auth-service-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auth_service_task_count_target07_a8_ccd2[0].resource_id
  scalable_dimension = aws_appautoscaling_target.auth_service_task_count_target07_a8_ccd2[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.auth_service_task_count_target07_a8_ccd2[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "auth_service_task_count_target_scale_on_cpu0847_acec" {
  count               = local.AuthAutoScalingEnabled0CD7354E ? 1 : 0
  resource_group_name = "SupabaseAuthServiceTaskCountTargetScaleOnCpu253117F9"
}

resource "aws_ssm_parameter" "auth_provider1_client_id_parameter_a8_cdd11_d" {
  description = "The OAuth2 Client ID registered with the external provider."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "Provider1", "/ClientId"])
  type        = "String"
  value       = local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_client_id5614_d178 : "null"
}

resource "aws_ssm_parameter" "auth_provider1_secret_parameter32101_b7_a" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_name740_dd3_f6 : "Provider1", "/Secret"])
  type        = "String"
  value       = local.AuthProvider1Enabled983DA6B5 ? var.auth_provider1_secret_ae54364_f : "null"
}

resource "aws_ssm_parameter" "auth_provider2_client_id_parameter30_d2_a6_d6" {
  description = "The OAuth2 Client ID registered with the external provider."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "Provider2", "/ClientId"])
  type        = "String"
  value       = local.AuthProvider2Enabled05B8862B ? var.auth_provider2_client_id_f3685_a2_b : "null"
}

resource "aws_ssm_parameter" "auth_provider2_secret_parameter4_b28_a4_be" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider2Enabled05B8862B ? var.auth_provider2_name573986_e5 : "Provider2", "/Secret"])
  type        = "String"
  value       = local.AuthProvider2Enabled05B8862B ? var.auth_provider2_secret2662_f55_e : "null"
}

resource "aws_ssm_parameter" "auth_provider3_client_id_parameter6_da38073" {
  description = "The OAuth2 Client ID registered with the external provider."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "Provider3", "/ClientId"])
  type        = "String"
  value       = local.AuthProvider3Enabled464D1673 ? var.auth_provider3_client_id8_df3_c6_f7 : "null"
}

resource "aws_ssm_parameter" "auth_provider3_secret_parameter7_a77_f7_f4" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  name        = join("", ["/", local.stack_name, "/Auth/External/", local.AuthProvider3Enabled464D1673 ? var.auth_provider3_name_a8_a7785_f : "Provider3", "/Secret"])
  type        = "String"
  value       = local.AuthProvider3Enabled464D1673 ? var.auth_provider3_secret29364_f33 : "null"
}

resource "aws_iam_role" "rest_task_def_task_role59_e8_d431" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "rest_task_def716_bd951" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "PGRST_DB_SCHEMAS"
          Value = "public,storage,graphql_public"
        },
        {
          Name  = "PGRST_DB_ANON_ROLE"
          Value = "anon"
        },
        {
          Name  = "PGRST_DB_USE_LEGACY_GUCS"
          Value = "false"
        },
        {
          Name  = "PGRST_APP_SETTINGS_JWT_EXP"
          Value = var.jwt_expiry_limit
        }
      ]
      Essential = true
      Image     = var.rest_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.rest_logs_e8_b49088.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 3000
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "PGRST_DB_URI"
          ValueFrom = "${aws_secretsmanager_secret.databaseauthenticator_secret69_fa14_de.id}:uri::"
        },
        {
          Name      = "PGRST_JWT_SECRET"
          ValueFrom = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Name      = "PGRST_APP_SETTINGS_JWT_SECRET"
          ValueFrom = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.rest_task_size14_e11_a14]["cpu"]
  execution_role_arn = aws_iam_role.rest_task_def_execution_role8_e4_c9_f62.arn
  family             = "SupabaseRestTaskDef"
  memory             = local.mappings["TaskSize"][var.rest_task_size14_e11_a14]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.rest_task_def_task_role59_e8_d431.arn

  lifecycle {
    replace_triggered_by = [ aws_lambda_invocation.database_user_password_function_8_eb9_c ]
  }
}

resource "aws_iam_role" "rest_task_def_execution_role8_e4_c9_f62" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.rest_logs_e8_b49088.arn}:*"
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.databaseauthenticator_secret69_fa14_de.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        }
      ]
      Version = "2012-10-17"
    })
    name = "RestTaskDefExecutionRoleDefaultPolicy2E2B5505"
  }
}

resource "aws_cloudwatch_log_group" "rest_logs_e8_b49088" {
  name              = "/aws/ecs/RestLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "rest_service8812_c0_b2" {
  name    = "rest"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.RestServiceEnabledD6F99FCE ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.rest_service_security_group0_baea949.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 3000
    registry_arn   = aws_service_discovery_service.rest_service_cloudmap_service_a978698_c.arn
  }
  task_definition = aws_ecs_task_definition.rest_task_def716_bd951.arn

  depends_on = [ aws_lambda_invocation.database_migration993_f5_b9_c ]
}

resource "aws_security_group" "rest_service_security_group0_baea949" {
  description = "Supabase/Rest/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rest_service_security_groupfrom_supabase_kong_service_security_group_b3_c4_ac8_f300032126_e75" {
  description                  = "from SupabaseKongServiceSecurityGroupB3C4AC8F:3000"
  from_port                    = 3000
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rest_service_security_group0_baea949.id
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "rest_service_security_groupfrom_supabase_auth_service_security_group_c0652_d2330004_e9_de7_f5" {
  description                  = "from SupabaseAuthServiceSecurityGroupC0652D23:3000"
  from_port                    = 3000
  referenced_security_group_id = aws_security_group.auth_service_security_group6440464_f.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rest_service_security_group0_baea949.id
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "rest_service_security_groupfrom_supabase_storage_service_security_group_adf822_d430009563_cf9_c" {
  description                  = "from SupabaseStorageServiceSecurityGroupADF822D4:3000"
  from_port                    = 3000
  referenced_security_group_id = aws_security_group.storage_service_security_group_f6280_dc0.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rest_service_security_group0_baea949.id
  to_port                      = 3000
}

resource "aws_service_discovery_service" "rest_service_cloudmap_service_a978698_c" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "rest"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "rest_service_task_count_target8_c6_e8_e1_e" {
  count              = local.RestAutoScalingEnabled69452861 ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.rest_service8812_c0_b2.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "rest_service_scale_on_cpu" {
  count              = local.RestAutoScalingEnabled69452861 ? 1 : 0
  name               = "rest-service-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.rest_service_task_count_target8_c6_e8_e1_e[0].resource_id
  scalable_dimension = aws_appautoscaling_target.rest_service_task_count_target8_c6_e8_e1_e[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.rest_service_task_count_target8_c6_e8_e1_e[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "rest_service_task_count_target_scale_on_cpu_e9845870" {
  count               = local.RestAutoScalingEnabled69452861 ? 1 : 0
  resource_group_name = "SupabaseRestServiceTaskCountTargetScaleOnCpuB529B263"
}

resource "aws_iam_role" "realtime_task_def_task_role3682_e469" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "realtime_task_def9_e0_dd838" {
  container_definitions = jsonencode([
    {
      Command = [
        "sh",
        "-c",
        "/app/bin/migrate && /app/bin/realtime eval \"Realtime.Release.seeds(Realtime.Repo)\" && /app/bin/server"
      ]
      EntryPoint = [
        "/usr/bin/tini",
        "-s",
        "-g",
        "--"
      ]
      Environment = [
        {
          Name  = "PORT"
          Value = "4000"
        },
        {
          Name  = "DB_HOST"
          Value = aws_rds_cluster.database_cluster5_b53_a178.endpoint
        },
        {
          Name  = "DB_PORT"
          Value = tostring(aws_rds_cluster.database_cluster5_b53_a178.port)
        },
        {
          Name  = "DB_AFTER_CONNECT_QUERY"
          Value = "SET search_path TO realtime"
        },
        {
          Name  = "DB_ENC_KEY"
          Value = "supabaserealtime"
        },
        {
          Name  = "FLY_ALLOC_ID"
          Value = "fly123"
        },
        {
          Name  = "FLY_APP_NAME"
          Value = "realtime"
        },
        {
          Name  = "ERL_AFLAGS"
          Value = "-proto_dist inet_tcp"
        },
        {
          Name  = "ENABLE_TAILSCALE"
          Value = "false"
        },
        {
          Name  = "DNS_NODES"
          Value = "realtime-dev.supabase.internal"
        }
      ]
      Essential = true
      Image     = var.realtime_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.realtime_logs5_c43159_d.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 4000
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "DB_USER"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:username::"
        },
        {
          Name      = "DB_PASSWORD"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:password::"
        },
        {
          Name      = "DB_NAME"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:dbname::"
        },
        {
          Name      = "API_JWT_SECRET"
          ValueFrom = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Name      = "SECRET_KEY_BASE"
          ValueFrom = aws_secretsmanager_secret.cookie_signing_secret_e5797145.id
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.realtime_task_size6077_fe1_f]["cpu"]
  execution_role_arn = aws_iam_role.realtime_task_def_execution_role578_aa7_f5.arn
  family             = "SupabaseRealtimeTaskDef0EF41020"
  memory             = local.mappings["TaskSize"][var.realtime_task_size6077_fe1_f]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.realtime_task_def_task_role3682_e469.arn
}

resource "aws_iam_role" "realtime_task_def_execution_role578_aa7_f5" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.realtime_logs5_c43159_d.arn}:*"
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.cookie_signing_secret_e5797145.id
        }
      ]
      Version = "2012-10-17"
    })
    name = "RealtimeTaskDefExecutionRoleDefaultPolicyD46A3DCC"
  }
}

resource "aws_cloudwatch_log_group" "realtime_logs5_c43159_d" {
  name              = "/aws/ecs/RealtimeLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "realtime_service_a39_af596" {
  name    = "realtime"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.RealtimeServiceEnabled18ED891C ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.realtime_service_security_group8_e245_e7_e.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 4000
    registry_arn   = aws_service_discovery_service.realtime_service_cloudmap_service_bbba4_a23.arn
  }
  task_definition = aws_ecs_task_definition.realtime_task_def9_e0_dd838.arn
}

resource "aws_security_group" "realtime_service_security_group8_e245_e7_e" {
  description = "Supabase/Realtime/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }


  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "realtime_service_security_groupfrom_supabase_realtime_service_security_group570992_fealltraffic599_b2469" {
  description                  = "from SupabaseRealtimeServiceSecurityGroup570992FE:ALL TRAFFIC"
  referenced_security_group_id = aws_security_group.realtime_service_security_group8_e245_e7_e.id
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.realtime_service_security_group8_e245_e7_e.id
}

resource "aws_vpc_security_group_ingress_rule" "realtime_service_security_groupfrom_supabase_kong_service_security_group_b3_c4_ac8_f40007_d995_f01" {
  description                  = "from SupabaseKongServiceSecurityGroupB3C4AC8F:4000"
  from_port                    = 4000
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.realtime_service_security_group8_e245_e7_e.id
  to_port                      = 4000
}

resource "aws_service_discovery_service" "realtime_service_cloudmap_service_bbba4_a23" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "realtime-dev"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "realtime_service_task_count_target89349_cd4" {
  count              = local.RealtimeAutoScalingEnabled7991ED3B ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.realtime_service_a39_af596.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out" {
  count              = local.RealtimeAutoScalingEnabled7991ED3B ? 1 : 0
  name               = "scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.realtime_service_task_count_target89349_cd4[0].resource_id
  scalable_dimension = aws_appautoscaling_target.realtime_service_task_count_target89349_cd4[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.realtime_service_task_count_target89349_cd4[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "realtime_service_task_count_target_scale_on_cpu764115_ff" {
  count               = local.RealtimeAutoScalingEnabled7991ED3B ? 1 : 0
  resource_group_name = "SupabaseRealtimeServiceTaskCountTargetScaleOnCpu2482C1E2"
}


resource "aws_s3_bucket" "bucket83908_e77" {
  bucket = "supabase-83908e77"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket83908_e77" {
  bucket = aws_s3_bucket.bucket83908_e77.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket83908_e77" {
  bucket = aws_s3_bucket.bucket83908_e77.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "imgproxy_task_def_task_role_b88_d5_b6_d" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "imgproxy_task_def33_bf8_cea" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "IMGPROXY_BIND"
          Value = ":5001"
        },
        {
          Name  = "IMGPROXY_LOCAL_FILESYSTEM_ROOT"
          Value = "/"
        },
        {
          Name  = "IMGPROXY_USE_ETAG"
          Value = "true"
        },
        {
          Name  = "IMGPROXY_ENABLE_WEBP_DETECTION"
          Value = "true"
        }
      ]
      Essential = true
      HealthCheck = {
        Command = [
          "CMD",
          "imgproxy",
          "health"
        ]
        Interval = 5
        Retries  = 3
        Timeout  = 5
      }
      Image = var.imgproxy_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.imgproxy_logs00_a67_bbb.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 5001
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.imgproxy_task_size5_d0_dd9_f6]["cpu"]
  execution_role_arn = aws_iam_role.imgproxy_task_def_execution_role_e676_fd35.arn
  family             = "SupabaseImgproxyTaskDef08EEF13B"
  memory             = local.mappings["TaskSize"][var.imgproxy_task_size5_d0_dd9_f6]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.imgproxy_task_def_task_role_b88_d5_b6_d.arn
}

resource "aws_iam_role" "imgproxy_task_def_execution_role_e676_fd35" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.imgproxy_logs00_a67_bbb.arn}:*"
        }
      ]
      Version = "2012-10-17"
    })
    name = "ImgproxyTaskDefExecutionRoleDefaultPolicy28511DDA"
  }
}

resource "aws_cloudwatch_log_group" "imgproxy_logs00_a67_bbb" {
  name              = "/aws/ecs/ImgproxyLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_ecs_service" "imgproxy_service_c5851888" {
  name    = "imgproxy"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.ImgproxyServiceEnabled64E773FC ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.imgproxy_service_security_group_dd73_de99.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 5001
    registry_arn   = aws_service_discovery_service.imgproxy_service_cloudmap_service9_c9565_a1.arn
  }
  task_definition = aws_ecs_task_definition.imgproxy_task_def33_bf8_cea.arn
}

resource "aws_security_group" "imgproxy_service_security_group_dd73_de99" {
  description = "Supabase/Imgproxy/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "imgproxy_service_security_groupfrom_supabase_storage_service_security_group_adf822_d450011_e6_fa973" {
  description                  = "from SupabaseStorageServiceSecurityGroupADF822D4:5001"
  from_port                    = 5001
  referenced_security_group_id = aws_security_group.storage_service_security_group_f6280_dc0.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.imgproxy_service_security_group_dd73_de99.id
  to_port                      = 5001
}

resource "aws_service_discovery_service" "imgproxy_service_cloudmap_service9_c9565_a1" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "imgproxy"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "imgproxy_service_task_count_target_c19355_bf" {
  count              = local.ImgproxyAutoScalingEnabled44E9E87F ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.imgproxy_service_c5851888.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "imgproxy_scale_cpu" {
  count              = local.ImgproxyAutoScalingEnabled44E9E87F ? 1 : 0
  name               = "imgproxy-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.imgproxy_service_task_count_target_c19355_bf[0].resource_id
  scalable_dimension = aws_appautoscaling_target.imgproxy_service_task_count_target_c19355_bf[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.imgproxy_service_task_count_target_c19355_bf[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "imgproxy_service_task_count_target_scale_on_cpu_ade19_fc6" {
  count               = local.ImgproxyAutoScalingEnabled44E9E87F ? 1 : 0
  resource_group_name = "SupabaseImgproxyServiceTaskCountTargetScaleOnCpu2F1B6C7E"
}

resource "aws_iam_role" "storage_task_def_task_role_fb709706" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "s3:GetObject*",
            "s3:GetBucket*",
            "s3:List*",
            "s3:DeleteObject*",
            "s3:PutObject",
            "s3:PutObjectLegalHold",
            "s3:PutObjectRetention",
            "s3:PutObjectTagging",
            "s3:PutObjectVersionTagging",
            "s3:Abort*"
          ]
          Effect = "Allow"
          Resource = [
            aws_s3_bucket.bucket83908_e77.arn,
            join("", [aws_s3_bucket.bucket83908_e77.arn, "/*"])
          ]
        }
      ]
      Version = "2012-10-17"
    })
    name = "StorageTaskDefTaskRoleDefaultPolicy0587C2F8"
  }
}

resource "aws_ecs_task_definition" "storage_task_def36011_ffa" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "POSTGREST_URL"
          Value = "http://rest.supabase.internal:3000"
        },
        {
          Name  = "PGOPTIONS"
          Value = "-c search_path=storage,public"
        },
        {
          Name  = "FILE_SIZE_LIMIT"
          Value = "52428800"
        },
        {
          Name  = "STORAGE_BACKEND"
          Value = "s3"
        },
        {
          Name  = "TENANT_ID"
          Value = "stub"
        },
        {
          Name  = "IS_MULTITENANT"
          Value = "false"
        },
        {
          Name  = "REGION"
          Value = data.aws_region.current.name
        },
        {
          Name  = "GLOBAL_S3_BUCKET"
          Value = aws_s3_bucket.bucket83908_e77.id
        },
        {
          Name  = "ENABLE_IMAGE_TRANSFORMATION"
          Value = "true"
        },
        {
          Name  = "IMGPROXY_URL"
          Value = "http://imgproxy.supabase.internal:5001"
        },
        {
          Name  = "WEBHOOK_URL"
          Value = aws_lambda_function_url.cdn_cache_manager_api_function_function_url37928_fc6.function_url
        },
        {
          Name  = "ENABLE_QUEUE_EVENTS"
          Value = "false"
        }
      ]
      Essential = true
      HealthCheck = {
        Command = [
          "CMD",
          "wget",
          "--no-verbose",
          "--tries=1",
          "--spider",
          "http://localhost:5000/status"
        ]
        Interval = 5
        Retries  = 3
        Timeout  = 5
      }
      Image = var.storage_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          awslogs-group         = aws_cloudwatch_log_group.storage_logs2_a2_d4_d26.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 5000
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "ANON_KEY"
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_anon_key_parameter532_dcc06.name])
        },
        {
          Name      = "SERVICE_KEY"
          ValueFrom = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_service_role_key_parameter_b65536_eb.name])
        },
        {
          Name      = "PGRST_JWT_SECRET"
          ValueFrom = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Name      = "DATABASE_URL"
          ValueFrom = "${aws_secretsmanager_secret.databasesupabasestorageadmin_secret88_c76_aa3.id}:uri::"
        },
        {
          Name      = "WEBHOOK_API_KEY"
          ValueFrom = aws_secretsmanager_secret.cdn_cache_manager_api_key137_d2795.id
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.storage_task_size_b82_d9_cfb]["cpu"]
  execution_role_arn = aws_iam_role.storage_task_def_execution_role_a2_ef27_e4.arn
  family             = "SupabaseStorageTaskDef"
  memory             = local.mappings["TaskSize"][var.storage_task_size_b82_d9_cfb]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.storage_task_def_task_role_fb709706.arn
  lifecycle {
    replace_triggered_by = [ aws_lambda_invocation.database_user_password_function_8_eb9_c ]
  }
}

resource "aws_iam_role" "storage_task_def_execution_role_a2_ef27_e4" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.storage_logs2_a2_d4_d26.arn}:*"
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_anon_key_parameter532_dcc06.name])
        },
        {
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory"
          ]
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ssm:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":parameter", aws_ssm_parameter.jwt_secret_service_role_key_parameter_b65536_eb.name])
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.databasesupabasestorageadmin_secret88_c76_aa3.id
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.cdn_cache_manager_api_key137_d2795.id
        }
      ]
      Version = "2012-10-17"
    })
    name = "StorageTaskDefExecutionRoleDefaultPolicyCFBB4B95"
  }
}

resource "aws_cloudwatch_log_group" "storage_logs2_a2_d4_d26" {
  name              = "/aws/ecs/StorageLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "storage_service1_cff47_fc" {
  name    = "storage"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.StorageServiceEnabled58819374 ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.storage_service_security_group_f6280_dc0.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 5000
    registry_arn   = aws_service_discovery_service.storage_service_cloudmap_service524_ec31_c.arn
  }
  task_definition = aws_ecs_task_definition.storage_task_def36011_ffa.arn
}

resource "aws_security_group" "storage_service_security_group_f6280_dc0" {
  description = "Supabase/Storage/Service/SecurityGroup"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }


  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "storage_service_security_groupfrom_supabase_kong_service_security_group_b3_c4_ac8_f50000996_d63_b" {
  description                  = "from SupabaseKongServiceSecurityGroupB3C4AC8F:5000"
  from_port                    = 5000
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.storage_service_security_group_f6280_dc0.id
  to_port                      = 5000
}

resource "aws_service_discovery_service" "storage_service_cloudmap_service524_ec31_c" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "storage"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "storage_service_task_count_target_af72160_a" {
  count              = local.StorageAutoScalingEnabled4D34646B ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.storage_service1_cff47_fc.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "storage_service_scale_on_cpu" {
  count              = local.StorageAutoScalingEnabled4D34646B ? 1 : 0
  name               = "storage-service-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.storage_service_task_count_target_af72160_a[0].resource_id
  scalable_dimension = aws_appautoscaling_target.storage_service_task_count_target_af72160_a[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.storage_service_task_count_target_af72160_a[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "storage_service_task_count_target_scale_on_cpu_db3_b903_c" {
  count               = local.StorageAutoScalingEnabled4D34646B ? 1 : 0
  resource_group_name = "SupabaseStorageServiceTaskCountTargetScaleOnCpuE2C72C87"
}

resource "aws_iam_role" "meta_task_def_task_role_c662_b431" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_ecs_task_definition" "meta_task_def2_c490_dd3" {
  container_definitions = jsonencode([
    {
      Environment = [
        {
          Name  = "PG_META_PORT"
          Value = "8080" // Already a string
        },
        {
          Name  = "PG_META_DB_HOST"
          Value = aws_rds_cluster.database_cluster5_b53_a178.endpoint
        },
        {
          Name  = "PG_META_DB_PORT"
          Value = tostring(aws_rds_cluster.database_cluster5_b53_a178.port) // Convert port number to string
        }
      ]
      Essential = true
      Image     = var.postgres_meta_image_uri
      LogConfiguration = {
        LogDriver = "awslogs"
        Options = {
          "awslogs-group"         = aws_cloudwatch_log_group.meta_logs80_fd71_c7.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-region"        = data.aws_region.current.name
        }
      }
      Name = "app"
      PortMappings = [
        {
          ContainerPort = 8080
          Name          = "http"
          Protocol      = "tcp"
        }
      ]
      Secrets = [
        {
          Name      = "PG_META_DB_NAME"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:dbname::"
        },
        {
          Name      = "PG_META_DB_USER"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:username::"
        },
        {
          Name      = "PG_META_DB_PASSWORD"
          ValueFrom = "${aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id}:password::"
        }
      ]
      Ulimits = [
        {
          HardLimit = 65536
          Name      = "nofile"
          SoftLimit = 65536
        }
      ]
    }
  ])
  cpu                = local.mappings["TaskSize"][var.meta_task_size556_d36_d9]["cpu"]
  execution_role_arn = aws_iam_role.meta_task_def_execution_role959286_b6.arn
  family             = "SupabaseMetaTaskDef48FB78F0"
  memory             = local.mappings["TaskSize"][var.meta_task_size556_d36_d9]["memory"]
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.meta_task_def_task_role_c662_b431.arn
}

resource "aws_iam_role" "meta_task_def_execution_role959286_b6" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.meta_logs80_fd71_c7.arn}:*"
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id
        }
      ]
      Version = "2012-10-17"
    })
    name = "MetaTaskDefExecutionRoleDefaultPolicy60F100A8"
  }
}

resource "aws_cloudwatch_log_group" "meta_logs80_fd71_c7" {
  name              = "/aws/ecs/MetaLogs" # Customize the name based on your naming convention
  retention_in_days = 30

  # Terraform automatically handles the lifecycle of the log group, similar to the "Delete" policies.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_service" "meta_service2_be3_a4_cf" {
  name    = "meta"
  cluster = aws_ecs_cluster.cluster_eb0386_a7.arn

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_controller {
    type = "ECS"
  }
  desired_count           = local.MetaServiceEnabled094DCF06 ? 1 : 0
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.meta_service_security_group0_e39_df35.id
    ]
    subnets = module.vpc.private_subnets
  }
  propagate_tags = "SERVICE"
  service_registries {
    container_name = "app"
    container_port = 8080
    registry_arn   = aws_service_discovery_service.meta_service_cloudmap_service638956_cc.arn
  }
  task_definition = aws_ecs_task_definition.meta_task_def2_c490_dd3.arn

  depends_on = [ aws_lambda_invocation.database_migration993_f5_b9_c ]
}

resource "aws_security_group" "meta_service_security_group0_e39_df35" {

  description = "Supabase/Meta/Service/SecurityGroup"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "meta_service_security_groupfrom_supabase_kong_service_security_group_b3_c4_ac8_f80805_ad2_c559" {
  description                  = "from SupabaseKongServiceSecurityGroupB3C4AC8F:8080"
  from_port                    = 8080
  referenced_security_group_id = aws_security_group.kong_service_security_group_e199_ee6_c.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.meta_service_security_group0_e39_df35.id
  to_port                      = 8080
}

resource "aws_service_discovery_service" "meta_service_cloudmap_service638956_cc" {
  dns_config {
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dns_records {
      ttl  = 10
      type = "A"
    }
    namespace_id   = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  name         = "meta"
  namespace_id = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.id
}

resource "aws_appautoscaling_target" "meta_service_task_count_target124_c5_bfa" {
  count              = local.MetaAutoScalingEnabledCF28EDB1 ? 1 : 0
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = join("", ["service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/", aws_ecs_service.meta_service2_be3_a4_cf.name])
  role_arn           = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "meta_service_scale_on_cpu" {
  count              = local.MetaAutoScalingEnabledCF28EDB1 ? 1 : 0
  name               = "meta-service-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.meta_service_task_count_target124_c5_bfa[0].resource_id
  scalable_dimension = aws_appautoscaling_target.meta_service_task_count_target124_c5_bfa[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.meta_service_task_count_target124_c5_bfa[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_applicationinsights_application" "meta_service_task_count_target_scale_on_cpu_bfdcf132" {
  count               = local.MetaAutoScalingEnabledCF28EDB1 ? 1 : 0
  resource_group_name = "SupabaseMetaServiceTaskCountTargetScaleOnCpuB433E25D"
}

resource "aws_iam_role" "force_deploy_job_state_machine_role_b8306_d93" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = local.mappings["ServiceprincipalMap"][data.aws_region.current.name]["states"]
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action   = "ecs:ListServices"
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = "ecs:UpdateService"
          Effect   = "Allow"
          Resource = join("", ["arn:", data.aws_partition.current.partition, ":ecs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":service/", aws_ecs_cluster.cluster_eb0386_a7.arn, "/*"])
        }
      ]
      Version = "2012-10-17"
    })
    name = "ForceDeployJobStateMachineRoleDefaultPolicyD8B5C2E1"
  }
}

resource "aws_sfn_state_machine" "force_deploy_job_state_machine528644_b1" {
  name     = "ForceDeployJobStateMachine"
  role_arn = aws_iam_role.force_deploy_job_state_machine_role_b8306_d93.arn

  definition = <<EOF
  {
    "StartAt": "CheckInput",
    "States": {
      "CheckInput": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.services",
            "IsPresent": true,
            "Next": "ForceDeployment"
          }
        ],
        "Default": "GetEcsServiceList"
      },
      "GetEcsServiceList": {
        "Type": "Task",
        "Next": "ForceDeployment",
        "Comment": "Fetch ECS Services",
        "Resource": "arn:${data.aws_partition.current.partition}:states:::aws-sdk:ecs:listServices",
        "Parameters": {
          "Cluster": "${aws_ecs_cluster.cluster_eb0386_a7.arn}"
        },
        "ResultSelector": {
          "services.$": "$.ServiceArns"
        }
      },
      "ForceDeployment": {
        "Type": "Map",
        "End": true,
        "ItemsPath": "$.services",
        "Parameters": {
          "service.$": "$$.Map.Item.Value"
        },
        "Iterator": {
          "StartAt": "ForceDeployEcsTask",
          "States": {
            "ForceDeployEcsTask": {
              "Type": "Task",
              "End": true,
              "Comment": "Force deploy ECS Tasks",
              "Resource": "arn:${data.aws_partition.current.partition}:states:::aws-sdk:ecs:updateService",
              "Parameters": {
                "Cluster": "${aws_ecs_cluster.cluster_eb0386_a7.arn}",
                "Service.$": "$.service",
                "ForceNewDeployment": true
              }
            }
          }
        }
      }
    }
  }
  EOF
}


resource "aws_iam_role" "force_deploy_job_state_machine_events_role3137_ab10" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  inline_policy {
    policy = jsonencode({
      Statement = [
        {
          Action   = "states:StartExecution"
          Effect   = "Allow"
          Resource = aws_sfn_state_machine.force_deploy_job_state_machine528644_b1.arn
        }
      ]
      Version = "2012-10-17"
    })
    name = "ForceDeployJobStateMachineEventsRoleDefaultPolicy485FD53C"
  }
}

resource "aws_cloudwatch_event_rule" "auth_parameter_changed2_fc322_f1" {
  description = "Supabase - Auth parameter changed"
  event_pattern = jsonencode({
    source = [
      "aws.ssm"
    ]
    detail-type = [
      "Parameter Store Change"
    ]
    detail = {
      name = [
        {
          prefix = join("", ["/", local.stack_name, "/Auth/"])
        }
      ]
      operation = [
        "Update"
      ]
    }
  })
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "invoke_step_function" {
  rule      = aws_cloudwatch_event_rule.auth_parameter_changed2_fc322_f1.name
  target_id = "Target0"
  arn       = aws_sfn_state_machine.force_deploy_job_state_machine528644_b1.arn

  input = jsonencode({
    services = [aws_ecs_service.auth_service_ba690728.cluster]
  })

  role_arn = aws_iam_role.force_deploy_job_state_machine_events_role3137_ab10.arn
}
