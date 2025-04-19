##############################################################################
# Resource group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance and bucket
##############################################################################

module "cos" {
  count                  = var.existing_scc_instance_crn == null ? 1 : 0
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.21.11"
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
  version           = "1.19.18"
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
  version           = "1.5.8"
  name              = "${var.prefix}-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
}


##############################################################################
# SCC instance
##############################################################################

module "create_scc_instance" {
  source                                 = "../.."
  instance_name                          = "${var.prefix}-instance"
  region                                 = var.region
  resource_group_id                      = module.resource_group.resource_group_id
  resource_tags                          = var.resource_tags
  existing_scc_instance_crn              = var.existing_scc_instance_crn
  access_tags                            = var.access_tags
  cos_bucket                             = var.existing_scc_instance_crn == null ? module.cos[0].bucket_name : null
  cos_instance_crn                       = var.existing_scc_instance_crn == null ? module.cos[0].cos_instance_id : null
  en_instance_crn                        = module.event_notification.crn
  en_source_name                         = "${var.prefix}-en-integration" # This name must be unique per SCC instance that is integrated with the Event Notifications instance.
  enable_event_notifications_integration = true
  skip_cos_iam_authorization_policy      = false
  skip_scc_wp_auth_policy                = false
  # enable workload protection integration
  attach_wp_to_scc_instance = true
  wp_instance_crn           = module.scc_wp.crn
  # example on how to add custom provider integration
  custom_integrations = [
    # example of custom integration
    {
      provider_name    = "Caveonix"
      integration_name = "${var.prefix}-caveonix"
    }
  ]
  cbr_rules = [
    {
      description      = "${var.prefix}-scc access only from vpc"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
}

##############################################################################
# SCC scope + attachment
##############################################################################

resource "ibm_scc_scope" "scope" {
  description = "A scope targeting a resource group"
  environment = "ibm-cloud"
  name        = "Terraform sample resource group scope"
  properties = {
    scope_type = "account.resource_group"
    scope_id   = module.resource_group.resource_group_id
  }
  instance_id = module.create_scc_instance.guid
}

module "create_profile_attachment" {
  source                 = "../../modules/attachment"
  profile_name           = "SOC 2"
  profile_version        = "latest"
  scc_instance_id        = module.create_scc_instance.guid
  attachment_name        = "${var.prefix}-attachment"
  attachment_description = "profile-attachment-description"
  attachment_schedule    = "every_7_days"
  scope_ids              = [ibm_scc_scope.scope.scope_id]
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.30.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}
