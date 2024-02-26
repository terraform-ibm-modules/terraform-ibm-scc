resource "ibm_scc_profile" "scc_profile_instance" {
    instance_id = var.instance_id

    dynamic "controls" {
        for_each = var.controls != null ? var.controls : []
        content {
            control_library_id = controls.value.control_library_id
            control_id = controls.value.control_id
        }
    }
    dynamic "default_parameters" {
        for_each = var.default_parameters != null ? var.default_parameters : []
        content {
            assessment_type = users.value.assessment_type
            assessment_id = users.value.assessment_id
            parameter_name = users.value.parameter_name
            parameter_default_value = users.value.parameter_default_value
            parameter_display_name = users.value.parameter_display_name
            parameter_type = users.value.parameter_type
        }
    }
    profile_description = var.profile_description
    profile_name = var.profile_name
    profile_type = var.profile_type
}