resource "ibm_scc_profile_attachment" "scc_profile_attachment" {
  profile_id  = var.profile_id
  instance_id = var.scc_instance_id
  name        = var.attachment_name
  description = var.attachment_description
  schedule    = var.attachment_schedule == "Null" ? null : var.attachment_schedule
  status      = var.attachment_schedule == "Null" ? "disabled" : "enabled"
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
    for_each = var.attachment_parameters
    content {
      parameter_name         = attachment_parameters.value["parameter_name"]
      parameter_display_name = attachment_parameters.value["parameter_display_name"]
      parameter_type         = attachment_parameters.value["parameter_type"]
      parameter_value        = attachment_parameters.value["parameter_value"]
      assessment_type        = attachment_parameters.value["assessment_type"]
      assessment_id          = attachment_parameters.value["assessment_id"]
    }
  }

  notifications {
    enabled = var.enable_notification
    controls {
      failed_control_ids = var.failed_control_ids
      threshold_limit    = var.threshold_limit
    }
  }
}
