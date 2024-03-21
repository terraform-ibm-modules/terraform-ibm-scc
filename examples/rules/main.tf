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
  rules = [
    {
      description = "new rule 1"
      version     = "1.0.0"
      import = {
        parameters = []
      }
      target = {
        service_name  = "kms"
        resource_kind = "instance"
        additional_target_attributes = [
          {
            "name" : "location",
            "operator" : "string_equals",
            "value" : "us-south"
          }
        ]
      }
    },
    {
      description = "new rule 2"
      version     = "1.0.0"
      import = {
        parameters = []
      }
      target = {
        service_name  = "kms"
        resource_kind = "instance"
        additional_target_attributes = [
          {
            "name" : "location",
            "operator" : "string_equals",
            "value" : "eu-de"
          }
        ]
      }
    }
  ]
}
