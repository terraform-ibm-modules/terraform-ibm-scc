module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "7.5.1"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cb"
}

module "create_scc_instance" {
  source                            = "../.."
  instance_name                     = "${var.prefix}-instance"
  region                            = var.region
  resource_group_id                 = module.resource_group.resource_group_id
  resource_tags                     = var.resource_tags
  cos_bucket                        = module.cos.bucket_name
  cos_instance_crn                  = module.cos.cos_instance_id
  skip_cos_iam_authorization_policy = false
}

module "create_scc_rules" {
  source          = "../../modules/rules"
  scc_instance_id = module.create_scc_instance.guid
  rules_version   = "1.0.0"
  rules = [
    {
      description = "new rule 1"
      import = {
        parameters = []
      }
      required_config = {
        description = "restrict endpoints"
        and = [
          {
            property = "endpoints_restricted",
            operator = "is_true"
          }
        ]
      }
      target = {
        service_name  = "kms"
        resource_kind = "instance"
        additional_target_attributes = [
          {
            "name" : "location",
            operator : "string_equals",
            value : "us-south"
          }
        ]
      }
    },
    {
      description = "new rule 2"
      import = {
        parameters = []
      }
      required_config = {
        description = "required config"
        and = [
          {
            property = "cloud_directory_enabled",
            operator = "is_true"
          },
          {
            property = "email_dispatcher_provider",
            operator = "string_not_equals"
            value    = "appid"
          }
        ]
      }
      target = {
        service_name                 = "appid",
        service_display_name         = "App ID",
        resource_kind                = "instance",
        additional_target_attributes = []
      }
    },
    {
      description = "new rule 3"
      import = {
        parameters = []
      }
      required_config = {
        description = "required config"
        or = [
          {
            and = [
              {
                property : "endpoints_restricted",
                operator : "is_true"
              },
              {
                property : "cbr_private_public_allowed_ip_list",
                operator : "is_empty"
              }
            ]
          },
          {
            and = [
              {
                property : "endpoints_restricted",
                operator : "is_true"
              },
              {
                property : "cbr_private_public_allowed_ip_list",
                operator : "is_not_empty"
              },
            ]
          },
          {
            and = [
              {
                property : "firewall.allowed_ip",
                operator : "is_not_empty"
              },
            ]
          }
        ]
      }
      target = {
        service_name                 = "cloud-object-storage",
        service_display_name         = "Cloud Object Storage",
        resource_kind                = "bucket",
        additional_target_attributes = []
      }
    }
  ]
}
