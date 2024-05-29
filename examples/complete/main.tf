##############################################################################
# Resource group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance and bucket
##############################################################################

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.2.10"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cb"
}

##############################################################################
# Event Notifications
##############################################################################

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.4.0"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}

##############################################################################
# SCC Workload Protection Instance
##############################################################################

module "scc_wp" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "1.3.0"
  name              = "${var.prefix}-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
}

##############################################################################
# SCC instance
##############################################################################

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
  attach_wp_to_scc_instance         = true
  skip_scc_wp_auth_policy           = false
  wp_instance_crn                   = module.scc_wp.crn
}

##############################################################################
# SCC attachment
##############################################################################

module "create_profile_attachment" {
  source                 = "../../modules/attachment"
  profile_name           = "IBM Cloud Framework for Financial Services"
  profile_version        = "latest"
  scc_instance_id        = module.create_scc_instance.guid
  attachment_name        = "${var.prefix}-attachment"
  attachment_description = "profile-attachment-description"
  attachment_schedule    = "every_7_days"
  # scope the attachment to a specific resource group
  scope = [{
    environment = "ibm-cloud"
    properties = [
      {
        name  = "scope_type"
        value = "account.resource_group"
      },
      {
        name  = "scope_id"
        value = module.resource_group.resource_group_id
      }
    ]
  }]
}
