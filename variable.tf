variable "disable_signup" {
  description = "When signup is disabled the only way to create new users is through invites. Defaults to false, all signups enabled."
  type        = string
  default     = "false"
}

variable "site_url" {
  description = "The base URL your site is located at. Currently used in combination with other settings to construct URLs used in emails."
  type        = string
  default     = "http://localhost:3000"
}

variable "redirect_urls" {
  description = "URLs that auth providers are permitted to redirect to post authentication"
  type        = string
}

variable "jwt_expiry_limit" {
  description = "How long tokens are valid for. Defaults to 3600 (1 hour), maximum 604,800 seconds (one week)."
  type        = string
  default     = 3600
}

variable "password_min_length" {
  description = "When signup is disabled the only way to create new users is through invites. Defaults to false, all signups enabled."
  type        = string
  default     = "8"
}

variable "email" {
  description = "This is the email address the emails are sent from. If Amazon WorkMail is enabled, it set \"noreply@supabase-<account_id>.awsapps.com\""
  type        = string
  default     = "noreply@example.com"
}

variable "sender_name" {
  description = "The From email sender name for all emails sent."
  type        = string
  default     = "Supabase"
}

variable "auth_image_uri" {
  description = "https://gallery.ecr.aws/supabase/gotrue"
  type        = string
  default     = "public.ecr.aws/supabase/gotrue:v2.110.0"
}

variable "rest_image_uri" {
  description = "https://gallery.ecr.aws/supabase/postgrest"
  type        = string
  default     = "public.ecr.aws/supabase/postgrest:v11.2.0"
}

variable "realtime_image_uri" {
  description = "https://gallery.ecr.aws/supabase/realtime"
  type        = string
  default     = "public.ecr.aws/supabase/realtime:v2.25.27"
}

variable "storage_image_uri" {
  description = "https://gallery.ecr.aws/supabase/storage-api"
  type        = string
  default     = "public.ecr.aws/supabase/storage-api:v0.43.11"
}

variable "imgproxy_image_uri" {
  description = "https://gallery.ecr.aws/supabase/imgproxy"
  type        = string
  default     = "public.ecr.aws/supabase/imgproxy:v1.2.0"
}

variable "postgres_meta_image_uri" {
  description = "https://gallery.ecr.aws/supabase/postgres-meta"
  type        = string
  default     = "public.ecr.aws/supabase/postgres-meta:v0.74.2"
}

variable "enable_high_availability" {
  description = "Enable auto-scaling and clustering (Multi-AZ)."
  type        = string
  default     = "false"
}

variable "web_acl_arn" {
  description = "Web ACL for CloudFront."
  type        = string
}

variable "min_acu" {
  description = "The minimum number of Aurora capacity units (ACU) for a DB instance in an Aurora Serverless v2 cluster."
  type        = string
  default     = 0.5
}

variable "max_acu" {
  description = "The maximum number of Aurora capacity units (ACU) for a DB instance in an Aurora Serverless v2 cluster."
  type        = string
  default     = 32
}

variable "ses_region" {
  description = "Amazon SES used for SMTP server. If you want to use Amazon WorkMail, need to set us-east-1, us-west-2 or eu-west-1."
  type        = string
  default     = "us-east-1"
}

variable "enable_work_mail" {
  description = "Enable test e-mail domain \"xxx.awsapps.com\" with Amazon WorkMail."
  type        = string
  default     = "false"
}

variable "kong_task_size93_c195_e9" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "auth_task_size9895_c206" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "auth_provider1_name740_dd3_f6" {
  description = "External Auth Provider Name"
  type        = string
}

variable "auth_provider1_client_id5614_d178" {
  description = "The OAuth2 Client ID registered with the external provider."
  type        = string
}

variable "auth_provider1_secret_ae54364_f" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  type        = string
}

variable "auth_provider2_name573986_e5" {
  description = "External Auth Provider Name"
  type        = string
}

variable "auth_provider2_client_id_f3685_a2_b" {
  description = "The OAuth2 Client ID registered with the external provider."
  type        = string
}

variable "auth_provider2_secret2662_f55_e" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  type        = string
}

variable "auth_provider3_name_a8_a7785_f" {
  description = "External Auth Provider Name"
  type        = string
}

variable "auth_provider3_client_id8_df3_c6_f7" {
  description = "The OAuth2 Client ID registered with the external provider."
  type        = string
}

variable "auth_provider3_secret29364_f33" {
  description = "The OAuth2 Client Secret provided by the external provider when you registered."
  type        = string
}

variable "rest_task_size14_e11_a14" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "realtime_task_size6077_fe1_f" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "imgproxy_task_size5_d0_dd9_f6" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "storage_task_size_b82_d9_cfb" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "meta_task_size556_d36_d9" {
  description = "Fargare task size"
  type        = string
  default     = "medium"
}

variable "studio_branch" {
  description = "Branch or tag - https://github.com/supabase/supabase/tags"
  type        = string
  default     = "v0.23.09"
}

