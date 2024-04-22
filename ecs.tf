# ECS cluster

resource "aws_service_discovery_private_dns_namespace" "cluster_default_service_discovery_namespace_c336_f9_b4" {
  name = "supabase.internal"
  vpc  = module.vpc.vpc_id
}

resource "aws_ecs_cluster" "cluster_eb0386_a7" {
  name = "supabase"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.cluster_default_service_discovery_namespace_c336_f9_b4.arn
  }

  
}

resource "aws_ecs_cluster_capacity_providers" "cluster3_da9_ccba" {
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
  cluster_name = aws_ecs_cluster.cluster_eb0386_a7.name
}