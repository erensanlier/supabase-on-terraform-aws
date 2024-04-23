locals {
  db_users = {
    "supabase_auth_admin"    = aws_secretsmanager_secret.databasesupabaseauthadmin_f9154_f88.arn,
    "supabase_storage_admin" = aws_secretsmanager_secret.databasesupabasestorageadmin_secret88_c76_aa3.arn,
    "authenticator"          = aws_secretsmanager_secret.databaseauthenticator_secret69_fa14_de.arn,
    "dashboard_user"         = aws_secretsmanager_secret.databasedashboarduser_secret102_d2_f3_b.arn,
    "postgres"               = aws_secretsmanager_secret.databasepostgres_secret8_e64_af98.arn,
  }
}

resource "aws_iam_role" "database_user_password_function_service_role_d208_dcc1" {
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
            "secretsmanager:PutSecretValue"
          ]
          Effect = "Allow"
          Resource = [
            aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.arn,
            aws_secretsmanager_secret.databasesupabaseauthadmin_f9154_f88.arn,
            aws_secretsmanager_secret.databasesupabasestorageadmin_secret88_c76_aa3.arn,
            aws_secretsmanager_secret.databaseauthenticator_secret69_fa14_de.arn,
            aws_secretsmanager_secret.databasedashboarduser_secret102_d2_f3_b.arn,
            aws_secretsmanager_secret.databasepostgres_secret8_e64_af98.arn
          ]
        },
        {
          NotAction = "secretsmanager:PutSecretValue"
          Effect    = "Allow"
          Resource  = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.arn
        }
      ]
      Version = "2012-10-17"
    })
    name = "DatabaseUserPasswordFunctionServiceRoleDefaultPolicy8E1C300C"
  }
}

resource "aws_security_group" "database_user_password_function_security_group2_c5_b42_fb" {
  description = "Automatic security group for Lambda Function SupabaseDatabaseUserPasswordFunction2F544B74"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_lambda_function" "database_user_password_function_afac7436" {
  function_name = "supabase-database-user-password"

  s3_bucket = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key    = "stable/9f9174dec158d89dd5bd125a21d30b9b3e198dc7291551f8793ce3d1fa23f29d.zip"

  description = "Supabase - DB user password function"
  environment {
    variables = {
      DB_SECRET_ARN                       = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
  handler = "index.handler"
  role    = aws_iam_role.database_user_password_function_service_role_d208_dcc1.arn
  runtime = "nodejs20.x"
  timeout = 10
  vpc_config {
    security_group_ids = [
      aws_security_group.database_user_password_function_security_group2_c5_b42_fb.id
    ]
    subnet_ids = module.vpc.private_subnets
  }
}

resource "aws_lambda_invocation" "database_user_password_function_8_eb9_c" {
  for_each = local.db_users

  function_name = aws_lambda_function.database_user_password_function_afac7436.function_name
  input = jsonencode({
    RequestType = "Create"
    ResourceProperties = {
      Username = each.key
      SecretId = each.value
    }
  })
  depends_on = [
    aws_lambda_function.database_user_password_function_afac7436,
    aws_rds_cluster_instance.database_cluster_instance1_e154_d1_e9,
    aws_lambda_invocation.database_migration993_f5_b9_c,
    aws_secretsmanager_secret_version.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb,
    aws_secretsmanager_secret_version.databasesupabaseauthadmin_f9154_f88,
    aws_secretsmanager_secret_version.databasesupabasestorageadmin_secret88_c76_aa3,
    aws_secretsmanager_secret_version.databaseauthenticator_secret69_fa14_de,
    aws_secretsmanager_secret_version.databasedashboarduser_secret102_d2_f3_b,
    aws_secretsmanager_secret_version.databasepostgres_secret8_e64_af98
  ]
  lifecycle {
    replace_triggered_by = [ 
        aws_secretsmanager_secret_version.databasesupabaseauthadmin_f9154_f88,
        aws_secretsmanager_secret_version.databasesupabasestorageadmin_secret88_c76_aa3,
        aws_secretsmanager_secret_version.databaseauthenticator_secret69_fa14_de,
        aws_secretsmanager_secret_version.databasedashboarduser_secret102_d2_f3_b,
        aws_secretsmanager_secret_version.databasepostgres_secret8_e64_af98
     ]
  }
}
