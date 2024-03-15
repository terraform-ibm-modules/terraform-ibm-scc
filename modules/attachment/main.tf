##############################################################################
# Variable validation
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_attachment_parameters = var.custom_attachment_parameters == null && !var.use_profile_default_parameters ? tobool("A value must be passed for 'custom_attachment_parameters' if 'use_profile_default_parameters' is set to false.") : true
}

##############################################################################
# SCC profile attachment
##############################################################################

data "ibm_scc_profile" "scc_profile" {
  instance_id = var.scc_instance_id
  profile_id  = var.profile_id
}

locals {
  attachment_parameters = var.use_profile_default_parameters ? data.ibm_scc_profile.scc_profile.default_parameters : var.custom_attachment_parameters
}

# Create the attachment
resource "ibm_scc_profile_attachment" "scc_profile_attachment" {
  profile_id  = var.profile_id
  instance_id = var.scc_instance_id
  name        = var.attachment_name
  description = var.attachment_description
  # To workaround https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5207 we set schedule to 'daily' here even though 'none' was passed in.
  # The end result will be the schedule being set to none since the 'status' option below sets that.
  schedule = var.attachment_schedule == "none" ? "daily" : var.attachment_schedule
  status   = var.attachment_schedule == "none" ? "disabled" : "enabled"

  dynamic "scope" {
    for_each = var.scope
    content {
      environment = scope.value["environment"]
      dynamic "properties" {
        for_each = scope.value["properties"]
        content {
          name  = properties.value["name"]
          value = properties.value["value"]
        }
      }
    }
  }

  dynamic "attachment_parameters" {
    for_each = local.attachment_parameters
    content {
      parameter_name         = attachment_parameters.value["parameter_name"]
      parameter_display_name = attachment_parameters.value["parameter_display_name"]
      parameter_type         = attachment_parameters.value["parameter_type"]
      parameter_value        = attachment_parameters.value["parameter_default_value"]
      assessment_type        = attachment_parameters.value["assessment_type"]
      assessment_id          = attachment_parameters.value["assessment_id"]
    }
  }

  notifications {
    enabled = var.enable_notification
    controls {
      failed_control_ids = var.notify_failed_control_ids
      threshold_limit    = var.notification_threshold_limit
    }
  }
}
