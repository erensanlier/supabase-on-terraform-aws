resource "aws_codecommit_repository" "studio_repository_e0_effbe2" {
  description     = "Supabase/Studio/Repository"
  repository_name = local.stack_name
}

resource "aws_iam_role" "studio_repository_import_function_service_role_c6_b8_ed58" {
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
}

resource "aws_iam_policy" "studio_repository_import_function_service_role_default_policy_a3265637" {
  policy = jsonencode({
    Statement = [
      {
        Action   = "codecommit:GitPull"
        Effect   = "Allow"
        Resource = aws_codecommit_repository.studio_repository_e0_effbe2.arn
      },
      {
        Action   = "codecommit:GitPush"
        Effect   = "Allow"
        Resource = aws_codecommit_repository.studio_repository_e0_effbe2.arn
      }
    ]
    Version = "2012-10-17"
  })
  name = "StudioRepositoryImportFunctionServiceRoleDefaultPolicyA3265637"
}

resource "aws_iam_role_policy_attachment" "studio_repository_import_function_service_role_default_policy_attachmentc6_b8_ed58" {
  policy_arn = aws_iam_policy.studio_repository_import_function_service_role_default_policy_a3265637.arn
  role       = aws_iam_role.studio_repository_import_function_service_role_c6_b8_ed58.name
}

resource "aws_lambda_function" "studio_repository_import_function_f87_c7_d62" {
  function_name = "StudioRepositoryImportFunction"
  s3_bucket     = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key        = "stable/9f3f18af1863bba5966d593a9787c1672fb7493177bf2897d8ffa2be2fc2b397.zip"

  description = "Clone to CodeCommit from remote repo (You can execute this function manually.)"
  environment {
    variables = {
      TARGET_REPO   = join("", ["codecommit::", data.aws_region.current.name, "://", aws_codecommit_repository.studio_repository_e0_effbe2.repository_name])
      SOURCE_REPO   = "https://github.com/supabase/supabase.git"
      SOURCE_BRANCH = var.studio_branch
      TARGET_BRANCH = "main"
    }
  }
  ephemeral_storage {
    size = 3072
  }
  handler     = "index.handler"
  memory_size = 4096
  role        = aws_iam_role.studio_repository_import_function_service_role_c6_b8_ed58.arn
  runtime     = "python3.12"
  timeout     = 900
}

resource "aws_lambda_invocation" "studio_repositorymain62_c45_c74" {
  function_name = aws_lambda_function.studio_repository_import_function_f87_c7_d62.function_name

  input = jsonencode({
    ResourceProperties = {
      SourceRepo   = "https://github.com/supabase/supabase.git",
      SourceBranch = var.studio_branch
    },
    RequestType = "Create" // No difference between Create and Update
  })

  depends_on = [aws_amplify_branch.studio_app_prod_branch_ed7568_cb, aws_codecommit_repository.studio_repository_e0_effbe2]
}


resource "aws_iam_role" "studio_role199_eaf11" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "amplify.amazonaws.com"
          }
        }
      ]
      Version = "2012-10-17"
    }
  )

  description = "The service role that will be used by AWS Amplify for SSR app logging."
  path        = "/service-role/"
}

resource "aws_iam_policy" "studio_role_default_policy289_cec37" {
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.databasedashboarduser_secret102_d2_f3_b.id
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
        Action   = "codecommit:GitPull"
        Effect   = "Allow"
        Resource = aws_codecommit_repository.studio_repository_e0_effbe2.arn
      }
    ]
    Version = "2012-10-17"
  })
  name = "StudioRoleDefaultPolicy289CEC37"
}

resource "aws_iam_role_policy_attachment" "studio_role_default_policy_attachment199_eaf11" {
  policy_arn = aws_iam_policy.studio_role_default_policy289_cec37.arn

  role = aws_iam_role.studio_role199_eaf11.name
}

resource "aws_amplify_app" "studio_app_e10_a3450" {
  name = "SupabaseStudio"
  auto_branch_creation_config {
    enable_basic_auth = false
  }
  build_spec = join("", [
    <<EOT
      version: 1
      applications:
        - appRoot: studio
          frontend:
            phases:
              preBuild:
                commands:
                  - echo POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $DB_SECRET_ARN --query SecretString | jq -r . | jq -r .password) >> .env.production
                  - echo SUPABASE_ANON_KEY=$(aws ssm get-parameter --region $SUPABASE_REGION --name $ANON_KEY_NAME --query Parameter.Value) >> .env.production
                  - echo SUPABASE_SERVICE_KEY=$(aws ssm get-parameter --region $SUPABASE_REGION --name $SERVICE_KEY_NAME --query Parameter.Value) >> .env.production
                  - env | grep -e STUDIO_PG_META_URL >> .env.production
                  - env | grep -e SUPABASE_ >> .env.production
                  - env | grep -e NEXT_PUBLIC_ >> .env.production
                  - cd ../
                  - npx turbo@1.10.3 prune --scope=studio
                  - npm clean-install
              build:
                commands:
                  - npx turbo run build --scope=studio --include-dependencies --no-deps
                  - npm prune --omit=dev
              postBuild:
                commands:
                  - cd studio
                  - rsync -av --ignore-existing .next/standalone/${aws_codecommit_repository.studio_repository_e0_effbe2.repository_name}/studio/ .next/standalone/
                  - rsync -av --ignore-existing .next/standalone/${aws_codecommit_repository.studio_repository_e0_effbe2.repository_name}/node_modules/ .next/standalone/node_modules/
                  - rm -rf .next/standalone/${aws_codecommit_repository.studio_repository_e0_effbe2.repository_name}
                  - cp .env .env.production .next/standalone/
                  - rsync -av --ignore-existing public/ .next/standalone/public/
                  - rsync -av --ignore-existing .next/static/ .next/standalone/.next/static/
            artifacts:
              baseDirectory: .next
              files:
                - "**/*"
            cache:
              paths:
                - node_modules/**/*
    EOT
  ])
  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  environment_variables = {
    NODE_OPTIONS              = "--max-old-space-size=4096"
    AMPLIFY_MONOREPO_APP_ROOT = "studio"
    AMPLIFY_DIFF_DEPLOY       = "false"
    _CUSTOM_IMAGE             = "public.ecr.aws/sam/build-nodejs18.x:1.103"
    STUDIO_PG_META_URL        = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name, "/pg"])
    SUPABASE_URL              = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name])
    SUPABASE_PUBLIC_URL       = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name])
    SUPABASE_REGION           = data.aws_region.current.name
    DB_SECRET_ARN             = aws_secretsmanager_secret.databasedashboarduser_secret102_d2_f3_b.id
    ANON_KEY_NAME             = aws_ssm_parameter.jwt_secret_anon_key_parameter532_dcc06.arn
    SERVICE_KEY_NAME          = aws_ssm_parameter.jwt_secret_service_role_key_parameter_b65536_eb.arn
  }
  iam_service_role_arn = aws_iam_role.studio_role199_eaf11.arn
  platform             = "WEB_COMPUTE"
  repository           = aws_codecommit_repository.studio_repository_e0_effbe2.clone_url_http
}

resource "aws_amplify_branch" "studio_app_prod_branch_ed7568_cb" {
  app_id                      = aws_amplify_app.studio_app_e10_a3450.id
  branch_name                 = "main"
  enable_auto_build           = true
  enable_pull_request_preview = true
  environment_variables = {
    NEXT_PUBLIC_SITE_URL = join("", ["https://main.", aws_amplify_app.studio_app_e10_a3450.id, ".amplifyapp.com"])
  }
  framework = "Next.js - SSR"
  stage     = "PRODUCTION"
}

resource "aws_iam_policy" "studio_amplify_ssr_logging_policy_b3151918" {
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = join("", ["arn:", data.aws_partition.current.partition, ":logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":log-group:/aws/amplify/", aws_amplify_app.studio_app_e10_a3450.id, ":log-stream:*"])
        Sid      = "PushLogs"
      },
      {
        Action   = "logs:CreateLogGroup"
        Effect   = "Allow"
        Resource = join("", ["arn:", data.aws_partition.current.partition, ":logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":log-group:/aws/amplify/*"])
        Sid      = "CreateLogGroup"
      },
      {
        Action   = "logs:DescribeLogGroups"
        Effect   = "Allow"
        Resource = join("", ["arn:", data.aws_partition.current.partition, ":logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":log-group:*"])
        Sid      = "DescribeLogGroups"
      }
    ]
    Version = "2012-10-17"
  })
  name = join("", ["AmplifySSRLoggingPolicy-", aws_amplify_app.studio_app_e10_a3450.id])
}

resource "aws_iam_role_policy_attachment" "studio_amplify_ssr_logging_policy_attachmentb3151918" {
  policy_arn = aws_iam_policy.studio_amplify_ssr_logging_policy_b3151918.arn
  role = aws_iam_role.studio_role199_eaf11.name
}