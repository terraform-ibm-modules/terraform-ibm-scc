data "ibm_scc_control_libraries" "scc_control_libraries" {
  instance_id = var.instance_id
}

locals {
  control_library_map = {
    for control_library in data.ibm_scc_control_libraries.scc_control_libraries.control_libraries :
    control_library.control_library_name => control_library if control_library.control_library_name == var.control_library_name
  }
}

data "ibm_scc_control_library" "scc_control_library" {
  count              = lookup(local.control_library_map, var.control_library_name, null) != null ? 1 : 0
  instance_id        = var.instance_id
  control_library_id = local.control_library_map[var.control_library_name].id
}

locals {
  controls_map = {
    for control in data.ibm_scc_control_library.scc_control_library[*].controls :
    control[0].control_name => control[0]
  }
}

resource "ibm_scc_control_library" "scc_control_library_instance" {
  instance_id                 = var.instance_id
  control_library_name        = var.control_library_name
  control_library_description = var.control_library_description
  control_library_type        = "custom"
  latest                      = var.latest
  version_group_label         = var.version_group_label == null ? data.ibm_scc_control_library.scc_control_library[0].version_group_label : var.version_group_label

  dynamic "controls" {
    for_each = var.controls != null ? var.controls : []
    content {
      control_name        = controls.value.control_name
      control_id          = lookup(local.controls_map, controls.value.control_name, null) == null ? controls.value.control_id : local.controls_map[controls.value.control_name].control_id
      control_description = controls.value.control_description
      control_category    = controls.value.control_category
      control_parent      = controls.value.control_parent
      control_tags        = controls.value.control_tags
      dynamic "control_specifications" {
        for_each = controls.value.control_specifications != null ? controls.value.control_specifications : []
        content {
          control_specification_id          = control_specifications.value.control_specification_id
          responsibility                    = control_specifications.value.responsibility
          component_id                      = control_specifications.value.component_id
          component_name                    = control_specifications.value.component_name
          environment                       = control_specifications.value.environment
          control_specification_description = control_specifications.value.control_specification_description
          dynamic "assessments" {
            for_each = control_specifications.value.assessments != null ? control_specifications.value.assessments : []
            content {
              assessment_id          = assessments.value.assessment_id
              assessment_method      = assessments.value.assessment_method
              assessment_type        = assessments.value.assessment_type
              assessment_description = assessments.value.assessment_description
              dynamic "parameters" {
                for_each = assessments.value.parameters != null ? assessments.value.parameters : []
                content {
                  parameter_name         = parameters.value.parameter_name
                  parameter_display_name = parameters.value.parameter_display_name
                  parameter_type         = parameters.value.parameter_type
                }
              }
            }
          }
        }
      }
      dynamic "control_docs" {
        for_each = controls.value.control_docs != null ? controls.value.control_docs : []
        content {
          control_docs_id   = control_docs.value.control_docs_id
          control_docs_type = control_docs.value.control_docs_type
        }
      }
      control_requirement = controls.value.control_requirement
      status              = controls.value.status
    }
  }
}
