resource "ibm_scc_profile_attachment" "scc_profile_attachment" {
  profile_id  = var.profile_id
  instance_id = var.scc_instance_id
  name        = var.attachment_name
  description = var.attachment_description
  schedule    = var.attachment_schedule
  status      = var.attachment_status

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

  notifications {
    enabled = false
    controls {
      failed_control_ids = []
      threshold_limit    = 14
    }
  }
}
