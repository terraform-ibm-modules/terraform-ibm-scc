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
  version                = "7.5.3"
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
  version           = "1.2.2"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}

##############################################################################
# SCC instance
##############################################################################

module "create_scc_instance" {
  source            = "../.."
  instance_name     = "${var.prefix}-instance"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  cos_bucket        = module.cos.bucket_name
  cos_instance_crn  = module.cos.cos_instance_id
  en_instance_crn   = module.event_notification.crn
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
  profile_id             = "f54b4962-06c6-46bb-bb04-396d9fa9bd60" # temporarily default to SOC 2 profile until provider add support to do data lookup by name https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5185)
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
