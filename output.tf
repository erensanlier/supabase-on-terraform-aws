output "studio_url" {
  description = "The dashboard for Supabase projects."
  value       = join("", ["https://", aws_amplify_branch.studio_app_prod_branch_ed7568_cb.branch_name, ".", aws_amplify_app.studio_app_e10_a3450.default_domain])
}

output "supabase_url" {
  description = "A RESTful endpoint for querying and managing your database."
  value       = join("", ["https://", aws_cloudfront_distribution.cdn_distribution149_fa6_c8.domain_name])
}

output "supabas_anon_key" {
  description = "This key is safe to use in a browser if you have enabled Row Level Security for your tables and configured policies."
  value       = jsondecode(aws_lambda_invocation.jwt_secret_anon_key63_f37_a1_e.result).Data.Value
}

