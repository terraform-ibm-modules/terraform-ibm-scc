##############################################################################
# Resource group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance and bucket
##############################################################################

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.5.3"
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
  version           = "1.6.8"
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
  version           = "1.3.1"
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
# SCC controls
##############################################################################

module "create_scc_controls" {
  source                      = "../../modules/controls/."
  instance_id                 = module.create_scc_instance.guid
  control_library_name        = "control_library_complete"
  control_library_description = "control_library_complete_description"
  latest                      = true
  controls = [
    {
      control_id          = "032a81ca-6ef7-4ac2-81ac-20ee4a780e3b"
      control_name        = "${var.prefix}-control-name"
      control_description = "Boundary Protection"
      control_category    = "System and Communications Protection"
      control_requirement = true
      status              = "enabled"
      control_tags        = []
      control_docs        = [{}]
      control_specifications = [
        {
          control_specification_id          = "5c7d6f88-a92f-4734-9b49-bd22b0900184"
          control_specification_description = "IBM Cloud"
          component_id                      = "iam-identity"
          component_name                    = "IAM Identity Service"
          environment                       = "ibm-cloud"
          assessments = [
            {
              assessment_type        = "automated"
              assessment_method      = "ibm-cloud-rule"
              assessment_id          = "rule-a637949b-7e51-46c4-afd4-b96619001bf1"
              assessment_description = "All assessments related to iam_identity"
              parameters = [
                {
                  parameter_name         = "session_invalidation_in_seconds"
                  parameter_display_name = "Sign out due to inactivity in seconds"
                  parameter_type         = "numeric"
                }
              ]
            }
          ]
          responsibility = "user"
        }
      ]
    }
  ]
}

##############################################################################
# SCC attachment
##############################################################################

module "create_profile_attachment" {
  source                 = "../../modules/attachment"
  profile_name           = "SOC 2"
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
  version          = "1.23.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}
