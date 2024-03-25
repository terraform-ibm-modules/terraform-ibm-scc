##############################################################################
# SCC rules
##############################################################################

resource "ibm_scc_rule" "scc_rule_instance" {
  count       = length(var.rules) > 0 ? length(var.rules) : 0
  instance_id = var.scc_instance_id
  description = var.rules[count.index].description

  dynamic "import" {
    for_each = length(var.rules[count.index].import.parameters) > 0 ? [var.rules[count.index].import] : []
    content {
      dynamic "parameters" {
        for_each = import.value.parameters
        content {
          name         = parameters.value.name
          display_name = parameters.value.display_name
          description  = parameters.value.description
          type         = parameters.value.type
        }
      }
    }
  }

  required_config {
    description = var.rules[count.index].required_config.description
    operator    = var.rules[count.index].required_config.operator
    property    = var.rules[count.index].required_config.property
    value       = var.rules[count.index].required_config.value
    dynamic "and" {
      for_each = var.rules[count.index].required_config.and == null ? [] : var.rules[count.index].required_config.and
      content {
        description = and.value.description
        property    = and.value.property
        operator    = and.value.operator
        value       = and.value.value
        dynamic "and" {
          for_each = and.value.and == null ? [] : and.value.and
          content {
            description = and.value.description
            property    = and.value.property
            operator    = and.value.operator
          }
        }
        dynamic "or" {
          for_each = and.value.or == null ? [] : and.value.or
          content {
            description = or.value.description
            property    = or.value.property
            operator    = or.value.operator
          }
        }
      }
    }
    dynamic "or" {
      for_each = var.rules[count.index].required_config.or == null ? [] : var.rules[count.index].required_config.or
      content {
        description = or.value.description
        property    = or.value.property
        operator    = or.value.operator
        value       = or.value.value
        dynamic "and" {
          for_each = or.value.and == null ? [] : or.value.and
          content {
            description = and.value.description
            property    = and.value.property
            operator    = and.value.operator
          }
        }
        dynamic "or" {
          for_each = or.value.or == null ? [] : or.value.or
          content {
            description = or.value.description
            property    = or.value.property
            operator    = or.value.operator
          }
        }
      }
    }
  }

  target {
    service_name         = var.rules[count.index].target.service_name
    service_display_name = var.rules[count.index].target.service_display_name
    resource_kind        = var.rules[count.index].target.resource_kind
    dynamic "additional_target_attributes" {
      for_each = var.rules[count.index].target.additional_target_attributes
      content {
        name     = additional_target_attributes.value.name
        operator = additional_target_attributes.value.operator
        value    = additional_target_attributes.value.value
      }
    }
  }
  version = var.rules_version
}
