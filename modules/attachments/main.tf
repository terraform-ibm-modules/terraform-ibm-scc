resource "ibm_scc_profile_attachment" "scc_profile_attachment" {
  profile_id  = var.profile_id
  instance_id = var.scc_instance_id
  name        = var.attachment_name
  description = var.attachment_description
  schedule    = var.attachment_schedule
  status      = var.attachment_status
  scope {
    environment = var.environment
    dynamic "properties" {
      for_each = var.scope_properties
      iterator = property
      content {
        name  = property.value["name"]
        value = property.value["value"]
      }
    }
  }
}
