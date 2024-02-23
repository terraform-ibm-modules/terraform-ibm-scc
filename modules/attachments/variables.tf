variable "profile_id" {
  type        = string
  description = "The profile ID"
}

variable "scc_instance_id" {
  type        = string
  description = " The ID of the SCC instance in a particular region"
}

variable "attachment_name" {
  type        = string
  description = "The name of the SCC profile attachment"
}

variable "attachment_description" {
  type        = string
  description = "The description for the SCC profile attachment"
}

variable "attachment_schedule" {
  type        = string
  description = "The schedule of an attachment evaluation. Allowable values are: daily, every_7_days, every_30_days"
}

variable "attachment_status" {
  type        = string
  description = "The status of an attachment evaluation. Allowable values are: enabled, disabled"
}

variable "environment" {
  type        = string
  description = "The environment that relates to this scope"
}

variable "scope_properties" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(List) The properties supported for scoping by this environment"
}
