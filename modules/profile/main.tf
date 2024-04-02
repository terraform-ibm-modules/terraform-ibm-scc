data "ibm_scc_control_libraries" "scc_control_libraries" {
  instance_id = var.instance_id
}

locals {
  control_libraries = flatten([for control_library in data.ibm_scc_control_libraries.scc_control_libraries.control_libraries : [
    for ctrl in var.control_libraries :
    control_library if ctrl.control_library_name == control_library.control_library_name && ctrl.control_library_version == control_library.control_library_version
    ]
  ])
}

data "ibm_scc_control_library" "scc_control_library" {
  count              = length(var.control_libraries)
  instance_id        = var.instance_id
  control_library_id = local.control_libraries[count.index].id
}

locals {
  controls_map = flatten([
    for index, control_library in local.control_libraries : [
      for control in data.ibm_scc_control_library.scc_control_library[index].controls : {
        control_library_id = control_library.id
        control_id         = control.control_id
      }
    ]
  ])
}

resource "ibm_scc_profile" "scc_profile_instance" {
  instance_id         = var.instance_id
  profile_description = var.profile_description
  profile_name        = var.profile_name
  profile_type        = "custom"

  dynamic "controls" {
    for_each = local.controls_map
    content {
      control_library_id = controls.value.control_library_id
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
}
