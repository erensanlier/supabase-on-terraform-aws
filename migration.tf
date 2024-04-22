resource "aws_iam_role" "database_migration_function_service_role_e25_c2000" {
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
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]),
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"])
  ]
  
  inline_policy {
    policy = jsonencode({
      Statement = [
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
    name = "DatabaseMigrationFunctionServiceRoleDefaultPolicyBAA52D03"
  }
}

resource "aws_security_group" "database_migration_function_security_group279_b26_a2" {
  description = "Automatic security group for Lambda Function SupabaseDatabaseMigrationFunction60EA2449"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }
  vpc_id = module.vpc.vpc_id
}

resource "aws_lambda_function" "database_migration_function9_cbe9_ea5" {
  function_name = "supabase-database-migration"
  s3_bucket     = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key        = "stable/60462bc764e8693b2d4b7dedf023e7763a7c011bc319950aed1b8ce75299f6a7.zip"
  description   = "Supabase - Database migration function"

  environment {
    variables = {
      DB_SECRET_ARN                       = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }

  handler = "index.handler"
  role    = aws_iam_role.database_migration_function_service_role_e25_c2000.arn
  runtime = "nodejs20.x"
  timeout = 60

  vpc_config {
    security_group_ids = [aws_security_group.database_migration_function_security_group279_b26_a2.id]
    subnet_ids         = module.vpc.private_subnets
  }
}

resource "aws_lambda_invocation" "database_migration993_f5_b9_c" {
  function_name = aws_lambda_function.database_migration_function9_cbe9_ea5.function_name

  input = jsonencode({
    RequestType = "Create"
    ResourceProperties = {
    }
  })

  depends_on = [
    aws_lambda_function.database_migration_function9_cbe9_ea5,
    aws_secretsmanager_secret_version.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb
  ]
}
