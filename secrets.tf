# DB Cluster Secrets

resource "random_password" "supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb" {
  length  = 30
  special = false
}

resource "aws_secretsmanager_secret" "supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb" {
  name        = "${local.stack_name}-database-cluster"
  description = join("", ["Generated by the CDK for stack: ", local.stack_name])

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb" {
  secret_id = aws_secretsmanager_secret.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.id

  secret_string = jsonencode({
    username = aws_rds_cluster.database_cluster5_b53_a178.master_username
    password = aws_rds_cluster.database_cluster5_b53_a178.master_password
    dbname   = "postgres"
    host     = aws_rds_cluster.database_cluster5_b53_a178.endpoint
    port     = aws_rds_cluster.database_cluster5_b53_a178.port
  })
}

# DB User: supabase_auth_admin
resource "random_password" "databasesupabaseauthadmin_f9154_f88" {
  length           = 30
  special          = true
  override_special = "-_=^"
}

resource "aws_secretsmanager_secret" "databasesupabaseauthadmin_f9154_f88" {
  name        = "${local.stack_name}-database-supabase-auth-admin"
  description = "Supabase - Database User supabase_auth_admin"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "databasesupabaseauthadmin_f9154_f88" {
  secret_id = aws_secretsmanager_secret.databasesupabaseauthadmin_f9154_f88.id
  secret_string = jsonencode({
    username = "supabase_auth_admin",
    password = random_password.databasesupabaseauthadmin_f9154_f88.result
  })
}


# DB User: supabase_storage_admin
resource "random_password" "databasesupabasestorageadmin_secret88_c76_aa3" {
  length           = 30
  special          = true
  override_special = "-_=^"
}

resource "aws_secretsmanager_secret" "databasesupabasestorageadmin_secret88_c76_aa3" {
  name        = "${local.stack_name}-database-supabase-storage-admin"
  description = "Supabase - Database User supabase_storage_admin"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "databasesupabasestorageadmin_secret88_c76_aa3" {
  secret_id = aws_secretsmanager_secret.databasesupabasestorageadmin_secret88_c76_aa3.id

  secret_string = jsonencode({
    username = "supabase_storage_admin",
    password = random_password.databasesupabasestorageadmin_secret88_c76_aa3.result
  })
}

# DB User: authenticator
resource "random_password" "databaseauthenticator_secret69_fa14_de" {
  length           = 30
  special          = true
  override_special = "-_=^"
}

resource "aws_secretsmanager_secret" "databaseauthenticator_secret69_fa14_de" {
  name        = "${local.stack_name}-database-authenticator"
  description = "Supabase - Database User authenticator"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "databaseauthenticator_secret69_fa14_de" {
  secret_id = aws_secretsmanager_secret.databaseauthenticator_secret69_fa14_de.id

  secret_string = jsonencode({
    username = "authenticator",
    password = random_password.databaseauthenticator_secret69_fa14_de.result
  })
}

# DB User: dashboard_user
resource "random_password" "databasedashboarduser_secret102_d2_f3_b" {
  length           = 30
  special          = true
  override_special = "-_=^"
}

resource "aws_secretsmanager_secret" "databasedashboarduser_secret102_d2_f3_b" {
  name        = "${local.stack_name}-database-dashboard-user"
  description = "Supabase - Database User dashboard_user"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "databasedashboarduser_secret102_d2_f3_b" {
  secret_id = aws_secretsmanager_secret.databasedashboarduser_secret102_d2_f3_b.id

  secret_string = jsonencode({
    username = "dashboard_user",
    password = random_password.databasedashboarduser_secret102_d2_f3_b.result
  })
}

# DB User: postgres
resource "random_password" "databasepostgres_secret8_e64_af98" {
  length           = 30
  special          = true
  override_special = "-_=^"
}

resource "aws_secretsmanager_secret" "databasepostgres_secret8_e64_af98" {
  name        = "${local.stack_name}-database-postgres"
  description = "Supabase - Database User postgres"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "databasepostgres_secret8_e64_af98" {
  secret_id = aws_secretsmanager_secret.databasepostgres_secret8_e64_af98.id

  secret_string = jsonencode({
    username = "postgres",
    password = random_password.databasepostgres_secret8_e64_af98.result
  })
}

# JWT Secret

resource "random_password" "jwt_secret_b8834_b39" {
  length  = 64
  special = false # Set special to false to exclude punctuation
}

resource "aws_secretsmanager_secret" "jwt_secret_b8834_b39" {
  name        = "${local.stack_name}-json-web-token-secret"
  description = "${local.stack_name} - Json Web Token Secret"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "jwt_secret_b8834_b39" {
  secret_id = aws_secretsmanager_secret.jwt_secret_b8834_b39.id
  secret_string = jsonencode({
    token = random_password.jwt_secret_b8834_b39.result
  })
}

# CDN Cache Manager API Key

resource "random_password" "cdn_cache_manager_api_key137_d2795" {
  length  = 30    # Specify the desired length of the API key
  special = false # Set to false to exclude punctuation
}

resource "aws_secretsmanager_secret" "cdn_cache_manager_api_key137_d2795" {
  name        = "${local.stack_name}-cdn-cache-manager-api-key"
  description = "Supabase - API key for CDN cache manager"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "cdn_cache_manager_api_key137_d2795" {
  secret_id = aws_secretsmanager_secret.cdn_cache_manager_api_key137_d2795.id
  secret_string = jsonencode({
    apiKey = random_password.cdn_cache_manager_api_key137_d2795.result
  })
}

# Cookie Signing Secret
resource "random_password" "cookie_signing_secret_e5797145" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "cookie_signing_secret_e5797145" {
  name        = "${local.stack_name}-cookie-signing-secret"
  description = "Supabase - Cookie Signing Secret for Realtime"

  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "cookie_signing_secret_e5797145" {
  secret_id = aws_secretsmanager_secret.cookie_signing_secret_e5797145.id
  secret_string = jsonencode({
    password = random_password.cookie_signing_secret_e5797145.result
  })
}

# SMTP Secrets

resource "aws_secretsmanager_secret" "smtp_secret_f89_cc16_b" {
  name        = "${local.stack_name}-smtp-secret"
  description = "Supabase - SMTP Secret"

  force_overwrite_replica_secret = true
}

# resource "aws_secretsmanager_secret_version" "smtp_secret_f89_cc16_b" {
#   secret_id = aws_secretsmanager_secret.smtp_secret_f89_cc16_b.id

#   secret_string = jsonencode({
#     username = local.WorkMailEnabled ? aws_cloudformation_stack.smtp_work_mail_nested_stack_work_mail_nested_stack_resource042_ecb25.outputs.SupabaseSmtpWorkMailOrganizationSupabaseBD859A4AEmail : aws_iam_user.smtp_user4973_df55.name,
#     password = aws_iam_access_key.smtp_access_key_ccad8_b7_d.secret
#     host     = local.WorkMailEnabled ? "smtp.mail.${var.ses_region}.awsapps.com" : "email-smtp.${var.ses_region}.amazonaws.com"
#   })
# }

resource "aws_secretsmanager_secret_version" "smtp_secret_f89_cc16_b" {
  secret_id = aws_secretsmanager_secret.smtp_secret_f89_cc16_b.id

  secret_string = jsonencode({
    username = aws_iam_user.smtp_user4973_df55.name,
    password = aws_iam_access_key.smtp_access_key_ccad8_b7_d.secret
    host     = "email-smtp.${var.ses_region}.amazonaws.com"
  })
}
