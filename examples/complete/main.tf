module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "7.5.0"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cb"
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.2.2"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}

module "create_scc_instance" {
  source                            = "../.."
  instance_name                     = "${var.prefix}-instance"
  region                            = var.region
  resource_group_id                 = module.resource_group.resource_group_id
  resource_tags                     = var.resource_tags
  cos_bucket                        = module.cos.bucket_name
  cos_instance_crn                  = module.cos.cos_instance_id
  en_instance_crn                   = module.event_notification.crn
  skip_cos_iam_authorization_policy = false
}

locals {
  scope = {
    environment = var.scc_scope_environment
    properties = [
      {
        name  = "scope_id"
        value = module.resource_group.resource_group_id
      },
      {
        name  = "scope_type"
        value = "account.resource_group"
      }
    ]
  }
}

module "create_profile_attachment" {
  count                  = var.scc_profile_id == null ? 0 : 1
  source                 = "../../modules/attachments/"
  profile_id             = var.scc_profile_id
  scc_instance_id        = module.create_scc_instance.id
  attachment_name        = var.scc_attachment_name
  attachment_description = var.scc_attachment_description
  attachment_schedule    = var.scc_attachment_schedule
  attachment_status      = var.scc_attachment_status
  environment            = local.scope.environment
  scope_properties       = local.scope.properties
}
