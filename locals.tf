locals {
  mappings = {
    TaskSize = {
      none = {
        cpu    = 256
        memory = 512
      }
      micro = {
        cpu    = 256
        memory = 512
      }
      small = {
        cpu    = 512
        memory = 1024
      }
      medium = {
        cpu    = 1024
        memory = 2048
      }
      large = {
        cpu    = 2048
        memory = 4096
      }
      xlarge = {
        cpu    = 4096
        memory = 8192
      }
      "2xlarge" = {
        cpu    = 8192
        memory = 16384
      }
      "4xlarge" = {
        cpu    = 16384
        memory = 32768
      }
    }
    ServiceprincipalMap = {
      af-south-1 = {
        states = "states.af-south-1.amazonaws.com"
      }
      ap-east-1 = {
        states = "states.ap-east-1.amazonaws.com"
      }
      ap-northeast-1 = {
        states = "states.ap-northeast-1.amazonaws.com"
      }
      ap-northeast-2 = {
        states = "states.ap-northeast-2.amazonaws.com"
      }
      ap-northeast-3 = {
        states = "states.ap-northeast-3.amazonaws.com"
      }
      ap-south-1 = {
        states = "states.ap-south-1.amazonaws.com"
      }
      ap-south-2 = {
        states = "states.ap-south-2.amazonaws.com"
      }
      ap-southeast-1 = {
        states = "states.ap-southeast-1.amazonaws.com"
      }
      ap-southeast-2 = {
        states = "states.ap-southeast-2.amazonaws.com"
      }
      ap-southeast-3 = {
        states = "states.ap-southeast-3.amazonaws.com"
      }
      ap-southeast-4 = {
        states = "states.ap-southeast-4.amazonaws.com"
      }
      ca-central-1 = {
        states = "states.ca-central-1.amazonaws.com"
      }
      cn-north-1 = {
        states = "states.cn-north-1.amazonaws.com"
      }
      cn-northwest-1 = {
        states = "states.cn-northwest-1.amazonaws.com"
      }
      eu-central-1 = {
        states = "states.eu-central-1.amazonaws.com"
      }
      eu-central-2 = {
        states = "states.eu-central-2.amazonaws.com"
      }
      eu-north-1 = {
        states = "states.eu-north-1.amazonaws.com"
      }
      eu-south-1 = {
        states = "states.eu-south-1.amazonaws.com"
      }
      eu-south-2 = {
        states = "states.eu-south-2.amazonaws.com"
      }
      eu-west-1 = {
        states = "states.eu-west-1.amazonaws.com"
      }
      eu-west-2 = {
        states = "states.eu-west-2.amazonaws.com"
      }
      eu-west-3 = {
        states = "states.eu-west-3.amazonaws.com"
      }
      il-central-1 = {
        states = "states.il-central-1.amazonaws.com"
      }
      me-central-1 = {
        states = "states.me-central-1.amazonaws.com"
      }
      me-south-1 = {
        states = "states.me-south-1.amazonaws.com"
      }
      sa-east-1 = {
        states = "states.sa-east-1.amazonaws.com"
      }
      us-east-1 = {
        states = "states.us-east-1.amazonaws.com"
      }
      us-east-2 = {
        states = "states.us-east-2.amazonaws.com"
      }
      us-gov-east-1 = {
        states = "states.us-gov-east-1.amazonaws.com"
      }
      us-gov-west-1 = {
        states = "states.us-gov-west-1.amazonaws.com"
      }
      us-iso-east-1 = {
        states = "states.amazonaws.com"
      }
      us-iso-west-1 = {
        states = "states.amazonaws.com"
      }
      us-isob-east-1 = {
        states = "states.amazonaws.com"
      }
      us-west-1 = {
        states = "states.us-west-1.amazonaws.com"
      }
      us-west-2 = {
        states = "states.us-west-2.amazonaws.com"
      }
    }
  }
  HighAvailability = var.enable_high_availability == "true"
  # WorkMailEnabled            = var.enable_work_mail == "true"
  CdnWafDisabledF333CA7D     = var.web_acl_arn == ""
  KongServiceEnabled5CB62A18 = !(var.kong_task_size93_c195_e9 == "none")
  KongAutoScalingEnabled41DC2F80 = alltrue([
    local.KongServiceEnabled5CB62A18,
    local.HighAvailability
  ])
  AuthServiceEnabled3234D87F = !(var.auth_task_size9895_c206 == "none")
  AuthAutoScalingEnabled0CD7354E = alltrue([
    local.AuthServiceEnabled3234D87F,
    local.HighAvailability
  ])
  AuthProvider1Enabled983DA6B5 = !(var.auth_provider1_name740_dd3_f6 == "")
  AuthProvider2Enabled05B8862B = !(var.auth_provider2_name573986_e5 == "")
  AuthProvider3Enabled464D1673 = !(var.auth_provider3_name_a8_a7785_f == "")
  RestServiceEnabledD6F99FCE   = !(var.rest_task_size14_e11_a14 == "none")
  RestAutoScalingEnabled69452861 = alltrue([
    local.RestServiceEnabledD6F99FCE,
    local.HighAvailability
  ])
  RealtimeServiceEnabled18ED891C = !(var.realtime_task_size6077_fe1_f == "none")
  RealtimeAutoScalingEnabled7991ED3B = alltrue([
    local.RealtimeServiceEnabled18ED891C,
    local.HighAvailability
  ])
  ImgproxyServiceEnabled64E773FC = !(var.imgproxy_task_size5_d0_dd9_f6 == "none")
  ImgproxyAutoScalingEnabled44E9E87F = alltrue([
    local.ImgproxyServiceEnabled64E773FC,
    local.HighAvailability
  ])
  StorageServiceEnabled58819374 = !(var.storage_task_size_b82_d9_cfb == "none")
  StorageAutoScalingEnabled4D34646B = alltrue([
    local.StorageServiceEnabled58819374,
    local.HighAvailability
  ])
  MetaServiceEnabled094DCF06 = !(var.meta_task_size556_d36_d9 == "none")
  MetaAutoScalingEnabledCF28EDB1 = alltrue([
    local.MetaServiceEnabled094DCF06,
    local.HighAvailability
  ])
  CDKMetadataAvailable = anytrue([anytrue([data.aws_region.current.name == "af-south-1", data.aws_region.current.name == "ap-east-1", data.aws_region.current.name == "ap-northeast-1", data.aws_region.current.name == "ap-northeast-2", data.aws_region.current.name == "ap-south-1", data.aws_region.current.name == "ap-southeast-1", data.aws_region.current.name == "ap-southeast-2", data.aws_region.current.name == "ca-central-1", data.aws_region.current.name == "cn-north-1", data.aws_region.current.name == "cn-northwest-1"]), anytrue([data.aws_region.current.name == "eu-central-1", data.aws_region.current.name == "eu-north-1", data.aws_region.current.name == "eu-south-1", data.aws_region.current.name == "eu-west-1", data.aws_region.current.name == "eu-west-2", data.aws_region.current.name == "eu-west-3", data.aws_region.current.name == "me-south-1", data.aws_region.current.name == "sa-east-1", data.aws_region.current.name == "us-east-1", data.aws_region.current.name == "us-east-2"]), anytrue([data.aws_region.current.name == "us-west-1", data.aws_region.current.name == "us-west-2"])])
  stack_name           = "gamcap3"
}

