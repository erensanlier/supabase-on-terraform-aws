resource "aws_rds_cluster_parameter_group" "database_parameter_group2_a921026" {
  description = "Parameter group for Supabase"
  family      = "aurora-postgresql15"

  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_tle,pg_stat_statements,pgaudit,pg_cron"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_slot_wal_keep_size"
    value        = "1024"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_subnet_group" "database_cluster_subnets5540150_d" {
  description = "Subnets for Cluster database"
  subnet_ids  = module.vpc.private_subnets
}

resource "aws_security_group" "database_cluster_security_group_fef1426_a" {
  description = "RDS security group"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_database_migration_function_security_group2273_cff4_indirect_port7_ebf4_aaa" {
  description                  = "from SupabaseDatabaseMigrationFunctionSecurityGroup2273CFF4:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.database_migration_function_security_group279_b26_a2.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_database_user_password_function_security_group71503_a07_indirect_port8134897_c" {
  description                  = "from SupabaseDatabaseUserPasswordFunctionSecurityGroup71503A07:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.database_user_password_function_security_group2_c5_b42_fb.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_auth_service_security_group_c0652_d23_indirect_port316_a82_a5" {
  description                  = "from SupabaseAuthServiceSecurityGroupC0652D23:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.auth_service_security_group6440464_f.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_rest_service_security_group_c3243_df3_indirect_port2_d0_b0423" {
  description                  = "from SupabaseRestServiceSecurityGroupC3243DF3:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.rest_service_security_group0_baea949.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_realtime_service_security_group570992_fe_indirect_port1_faa9_e4_f" {
  description                  = "from SupabaseRealtimeServiceSecurityGroup570992FE:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.realtime_service_security_group8_e245_e7_e.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_storage_service_security_group_adf822_d4_indirect_port3_ce1_b682" {
  description                  = "from SupabaseStorageServiceSecurityGroupADF822D4:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.storage_service_security_group_f6280_dc0.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id

}

resource "aws_vpc_security_group_ingress_rule" "database_cluster_security_groupfrom_supabase_meta_service_security_group8_c22_dd35_indirect_port496372_c3" {
  description                  = "from SupabaseMetaServiceSecurityGroup8C22DD35:{IndirectPort}"
  from_port                    = aws_rds_cluster.database_cluster5_b53_a178.port
  to_port                      = aws_rds_cluster.database_cluster5_b53_a178.port
  referenced_security_group_id = aws_security_group.meta_service_security_group0_e39_df35.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.database_cluster_security_group_fef1426_a.id
}

resource "aws_rds_cluster" "database_cluster5_b53_a178" {
  copy_tags_to_snapshot           = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.database_parameter_group2_a921026.id
  db_subnet_group_name            = aws_db_subnet_group.database_cluster_subnets5540150_d.id
  database_name                   = "postgres"
  engine                          = "aurora-postgresql"
  engine_version                  = "15.4"
  master_username                 = "supabase_admin"
  master_password                 = random_password.supabase_database_cluster_secret2_aa4_a5_cd3fdaad7efa858a3daf9490cf0a702aeb.result
  port                            = 5432
  enable_http_endpoint            = true
  serverlessv2_scaling_configuration {
    max_capacity = var.max_acu
    min_capacity = var.min_acu
  }
  storage_encrypted = true
  vpc_security_group_ids = [
    aws_security_group.database_cluster_security_group_fef1426_a.id
  ]
}

resource "aws_rds_cluster_instance" "database_cluster_instance1_e154_d1_e9" {
  count              = local.HighAvailability ? 2 : 1
  cluster_identifier = aws_rds_cluster.database_cluster5_b53_a178.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.database_cluster5_b53_a178.engine
  engine_version     = aws_rds_cluster.database_cluster5_b53_a178.engine_version
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "15.4"
}