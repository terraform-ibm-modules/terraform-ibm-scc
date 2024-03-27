variable "scc_instance_id" {
  type        = string
  description = "ID of the SCC instance in which to create the rules."
}

variable "rules_version" {
  type        = string
  description = "The version number of a rule."
}

variable "rules" {
  description = "The rules to set for the SCC rules."
  type = list(object({
    description = optional(string)
    operator    = optional(string)
    property    = optional(string)
    value       = optional(string)
    import = object({
      parameters = list(object({
        name         = optional(string)
        display_name = optional(string)
        description  = optional(string)
        type         = optional(string)
      }))
    })
    required_config = object({
      description = optional(string)
      operator    = optional(string)
      property    = optional(string)
      value       = optional(string)
      and = optional(list(
        object({
          description = optional(string)
          operator    = string
          property    = string
          value       = optional(string)
          and = optional(list(
            object({
              description = optional(string)
              operator    = string
              property    = string
              value       = optional(string)
            })
          ))
          or = optional(list(
            object({
              description = optional(string)
              operator    = string
              property    = string
              value       = optional(string)
            })
          ))
        })
      ))
      or = optional(list(
        object({
          description = optional(string)
          operator    = optional(string)
          property    = optional(string)
          value       = optional(string)
          and = optional(list(
            object({
              description = optional(string)
              operator    = string
              property    = string
              value       = optional(string)
            })
          ))
          or = optional(list(
            object({
              description = optional(string)
              operator    = string
              property    = string
              value       = optional(string)
            })
          ))
        })
      ))
    })
    target = object({
      service_name         = optional(string)
      service_display_name = optional(string)
      resource_kind        = optional(string)
      additional_target_attributes = list(object({
        name     = optional(string)
        operator = optional(string)
        value    = optional(string)
      }))
    })
  }))
}
