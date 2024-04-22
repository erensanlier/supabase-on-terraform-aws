# resource "aws_cloudformation_stack" "smtp_work_mail_nested_stack_work_mail_nested_stack_resource042_ecb25" {
#   name  = "smtp-work-mail-nested-stack"
#   count = local.WorkMailEnabled ? 1 : 0
#   parameters = {
#     referencetoSupabaseSesRegion184A3193Ref         = var.ses_region
#     referencetoSupabaseSmtpPassword76B56B34Password = aws_iam_access_key.smtp_access_key_ccad8_b7_d.secret
#   }
#   template_url = join("", ["https://s3.", data.aws_region.current.name, ".", data.aws_partition.current.dns_suffix, "/", "supabase-on-aws-${data.aws_region.current.name}", "/stable/03f62f4c6a40df766b2afaa523da311dff846927099d46e60851b49562d81e9f"])
# }

resource "aws_iam_policy" "smtp_send_email_policy_cca0_aa9_b" {
  policy = jsonencode({
    Statement = [
      {
        Action   = "ses:SendRawEmail",
        Effect   = "Allow",
        Resource = "*"
      }
    ],
    Version = "2012-10-17"
  })
  name = "SmtpSendEmailPolicyCCA0AA9B"
}

resource "aws_iam_user_policy_attachment" "smtp_send_email_policy_attachment_8_eb_9_c" {
  policy_arn = aws_iam_policy.smtp_send_email_policy_cca0_aa9_b.arn
  user       = aws_iam_user.smtp_user4973_df55.name
}

resource "aws_iam_user" "smtp_user4973_df55" {
  name = "supabase-smtp-user"
}

resource "aws_iam_access_key" "smtp_access_key_ccad8_b7_d" {
  user = aws_iam_user.smtp_user4973_df55.name
}

resource "aws_iam_role" "smtp_password_function_service_role_a0_a9_c3_a3" {
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

resource "aws_lambda_function" "smtp_password_function_dc49_b7_cc" {
  function_name = "supabase-smtp-password"
  s3_bucket     = "supabase-on-aws-${data.aws_region.current.name}"
  s3_key        = "stable/cbb9c0c24fa0ee781b61f07de9aab9f7fbd9d5fec8eed79f7c53870781adaf38.zip"
  description   = "Supabase - Generate SMTP Password Function"
  environment {
    variables = {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
  handler = "index.handler"
  role    = aws_iam_role.smtp_password_function_service_role_a0_a9_c3_a3.arn
  runtime = "nodejs20.x"
}