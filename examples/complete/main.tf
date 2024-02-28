module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "7.3.2"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cb1"
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.0.4"
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

module "create_scc_controls" {
  source                      = "../../controls/."
  instance_id                 = module.create_scc_instance.guid
  control_library_name        = "control_library_name"
  control_library_description = "control_library_description"
  control_library_type        = "custom"
  latest                      = true
  version_group_label         = "de38e8c4-2212-4e4b-8dcf-b021b98d8e43"
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

data "ibm_scc_control_library" "scc_control_library_data" {
  instance_id        = module.create_scc_instance.guid
  control_library_id = module.create_scc_controls.control_library_id
}

module "create_scc_profile" {
  source      = "../../profile/."
  instance_id = module.create_scc_instance.guid

  controls = [for scc_ins in data.ibm_scc_control_library.scc_control_library_data.controls :
    {
      control_library_id = module.create_scc_controls.control_library_id
      control_id         = scc_ins.control_id
    }
  ]

  profile_name        = "${var.prefix}-profile"
  profile_description = "scc-custom"
  profile_type        = "custom"
}
