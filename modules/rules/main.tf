##############################################################################
# Variable validation
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  # validate_attachment_parameters = var.custom_attachment_parameters == null && !var.use_profile_default_parameters ? tobool("A value must be passed for 'custom_attachment_parameters' if 'use_profile_default_parameters' is set to false.") : true
}

##############################################################################
# SCC rules
##############################################################################

resource "ibm_scc_rule" "scc_rule_instance" {
  for_each = var.rules
  instance_id = var.scc_instance_id
  description = each.value.description

  import {
    dynamic "parameters" {
      for_each = each.value.import["parameters"]
      content {
        name = parameters.value.name
        display_name = parameters.value.display_name
        description = parameters.value.description
        type = parameters.value.type
      }
    }
  }

  required_config {
    description = "description"
    and {
      description = "description"
      property = "endpoints_restricted"
      operator = "is_true"
    }
  }

  target {
    service_name = each.value.target["service_name"]
    service_display_name = each.value.target["service_display_name"]
    resource_kind = each.value.target["resource_kind"]
    dynamic "additional_target_attributes" {
      for_each = each.value.target["additional_target_attributes"]
      content {
        name = additional_target_attributes.value.name
        operator = additional_target_attributes.value.operator
        value = additional_target_attributes.value.value
      }
    }
  }
  version = "1.0.0"
}
