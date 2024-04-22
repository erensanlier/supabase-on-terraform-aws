# resource "aws_cloudformation_stack" "smtp_work_mail_nested_stack_work_mail_nested_stack_resource042_ecb25" {
#   name  = "smtp-work-mail-nested-stack"
#   count = local.WorkMailEnabled ? 1 : 0
#   parameters = {
#     referencetoSupabaseSesRegion184A3193Ref         = var.ses_region
#     referencetoSupabaseSmtpPassword76B56B34Password = aws_iam_access_key.smtp_access_key_ccad8_b7_d.secret
#   }
#   template_url = join("", ["https://s3.", data.aws_region.current.name, ".", data.aws_partition.current.dns_suffix, "/", "supabase-on-aws-${data.aws_region.current.name}", "/stable/03f62f4c6a40df766b2afaa523da311dff846927099d46e60851b49562d81e9f"])
# }