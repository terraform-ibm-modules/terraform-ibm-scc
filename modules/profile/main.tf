data "ibm_scc_control_libraries" "scc_control_libraries" {
    instance_id = "00000000-1111-2222-3333-444444444444"
}

locals {
  control_libraries = [for control_library in data.ibm_scc_control_libraries.scc_control_libraries[0].control_libraries : control_library if contains(var.var.control_library_names, control_library.control_library_name)]
}

resource "ibm_scc_profile" "scc_profile_instance" {
  instance_id = var.instance_id

  dynamic "controls" {
    for_each = locals.control_libraries
    content {
      control_library_id = controls.value.id
      control_id         = controls.value.control_id
    }
  }
  dynamic "default_parameters" {
    for_each = var.default_parameters != null ? var.default_parameters : []
    content {
      assessment_type         = default_parameters.value.assessment_type
      assessment_id           = default_parameters.value.assessment_id
      parameter_name          = default_parameters.value.parameter_name
      parameter_default_value = default_parameters.value.parameter_default_value
      parameter_display_name  = default_parameters.value.parameter_display_name
      parameter_type          = default_parameters.value.parameter_type
    }
  }
  profile_description = var.profile_description
  profile_name        = var.profile_name
  profile_type        = var.profile_type
}
