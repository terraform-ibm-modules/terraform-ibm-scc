data "ibm_scc_control_libraries" "scc_control_libraries" {
  instance_id = var.instance_id
}

locals {
  # Get control libraries id from their name and version specified in var.controls.control_library_name
  control_libraries = flatten([for control_library in data.ibm_scc_control_libraries.scc_control_libraries.control_libraries : [
    for ctrl in var.controls :
    control_library if ctrl.control_library_name == control_library.control_library_name && ctrl.control_library_version == control_library.control_library_version
    ]
  ])
}

data "ibm_scc_control_library" "scc_control_library" {
  count              = length(var.controls)
  instance_id        = var.instance_id
  control_library_id = local.control_libraries[count.index].id
}

locals {
  # Map out all controls from relevant control libraries
  all_controls_map = flatten([
    for index, control_library in local.control_libraries : [
      for control in data.ibm_scc_control_library.scc_control_library[index].controls : {
        control_library_id   = control_library.id
        control_library_name = control_library.control_library_name
        control_id           = control.control_id
        control_name         = control.control_name
      }
    ]
  ])

  # Get chosen controls from var.controls.control_name_list in local.all_controls_map
  relevant_controls_map = flatten([
    for ctrl_map in local.all_controls_map : [
      for control in var.controls : [
        for ctrl in control.control_name_list :
        ctrl_map if(ctrl_map.control_name == ctrl && ctrl_map.control_library_name == control.control_library_name) || control.add_all_controls
      ]
    ]
  ])
}

resource "ibm_scc_profile" "scc_profile_instance" {
  instance_id         = var.instance_id
  profile_description = var.profile_description
  profile_name        = var.profile_name
  profile_type        = "custom"
  profile_version     = var.profile_version

  dynamic "controls" {
    for_each = local.relevant_controls_map
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
