resource "aws_iam_role" "jwt_secret_json_web_token_function_service_role17_cf8128" {
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
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
        }
      ]
      Version = "2012-10-17"
    })
    name = "JwtSecretJsonWebTokenFunctionServiceRoleDefaultPolicyFEC3E7BA"
  }
}

resource "aws_lambda_function" "jwt_secret_json_web_token_function_f8_ba9_d2_a" {
  function_name = "supabase-jwt-secret-json-web-token"
  s3_bucket     = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key        = "stable/baf945a52f8e02b1131009f27d8b23a50b9eacc020ff363093145c8e6f5dbc01.zip"
  description   = join("", [local.stack_name, " - Generate token via jwt secret"])
  environment {
    variables = {
      JWT_SECRET_ARN                      = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
  handler = "index.handler"
  role    = aws_iam_role.jwt_secret_json_web_token_function_service_role17_cf8128.arn
  runtime = "nodejs20.x"
}

resource "aws_lambda_invocation" "jwt_secret_anon_key63_f37_a1_e" {
  function_name = aws_lambda_function.jwt_secret_json_web_token_function_f8_ba9_d2_a.function_name

  input = jsonencode({
    ResourceProperties = {
      Payload = {
        role = "anon"
      },
      Issuer    = "supabase",
      ExpiresIn = "10y"
    },
    RequestType = "Create" // No difference between Create and Update
  })

  depends_on = [
    aws_lambda_function.jwt_secret_json_web_token_function_f8_ba9_d2_a,
    aws_secretsmanager_secret.jwt_secret_b8834_b39
  ]
}

resource "aws_ssm_parameter" "jwt_secret_anon_key_parameter532_dcc06" {
  description = join("", [local.stack_name, " - Json Web Token, role: anon"])
  name        = join("", ["/", local.stack_name, "/JwtSecret/AnonKey"])
  type        = "String"
  value       = jsondecode(aws_lambda_invocation.jwt_secret_anon_key63_f37_a1_e.result).Data.Value
}

resource "aws_lambda_invocation" "jwt_secret_service_role_key_f0_f6_c193" {
  function_name = aws_lambda_function.jwt_secret_json_web_token_function_f8_ba9_d2_a.function_name

  input = jsonencode({
    ResourceProperties = {
      Payload = {
        role = "service_role"
      },
      Issuer    = "supabase",
      ExpiresIn = "10y"
    },
    RequestType = "Create" // No difference between Create and Update
  })

  depends_on = [
    aws_lambda_function.jwt_secret_json_web_token_function_f8_ba9_d2_a,
    aws_secretsmanager_secret.jwt_secret_b8834_b39
  ]
}

resource "aws_ssm_parameter" "jwt_secret_service_role_key_parameter_b65536_eb" {
  description = join("", [local.stack_name, " - Json Web Token, role: service_role"])
  name        = join("", ["/", local.stack_name, "/JwtSecret/ServiceRoleKey"])
  type        = "String"
  value       = jsondecode(aws_lambda_invocation.jwt_secret_service_role_key_f0_f6_c193.result).Data.Value
}