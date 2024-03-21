variable "scc_instance_id" {
  type        = string
  description = "ID of the SCC instance in which to create the attachment."
  default     = "57b7ac52-e837-484c-aa07-e3c2db815c44"
}

variable "rules" {
  description = "The rules to set for the SCC rules."
  type = list(object({
    description = string
    version     = string
    import = object({
      parameters = list(object({
        name         = optional(string)
        display_name = optional(string)
        description  = optional(string)
        type         = optional(string)
      }))
    })
    # required_config = object({
    #   description = string
    #   value = list(object({}))
    # })
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
