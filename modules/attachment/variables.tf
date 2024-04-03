variable "profile" {
  type = object({
    name    = string
    version = string
  })
  description = "The profile that is used for the attachment."
}

variable "scc_instance_id" {
  type        = string
  description = "ID of the SCC instance in which to create the attachment."
}

variable "attachment_name" {
  type        = string
  description = "The name to give to SCC profile attachment."
}

variable "attachment_description" {
  type        = string
  description = "The description for the SCC profile attachment."
}

variable "attachment_schedule" {
  type        = string
  description = "The schedule of an attachment. Allowable values are: daily, every_7_days, every_30_days, none."
  default     = "daily"

  validation {
    condition     = contains(["daily", "every_7_days", "every_30_days", "none"], var.attachment_schedule)
    error_message = "Allowed schedule can be - daily, every_7_days, every_30_days, none."
  }
}

variable "scope" {
  description = "The scope to set for the SCC profile attachment."
  type = list(object({
    environment = optional(string, "ibm-cloud")
    properties = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "use_profile_default_parameters" {
  description = "A boolean indicating whether to use the profiles default parameters. If set to false, a value must be passed for the `custum_attachment_parameters` input variable."
  type        = bool
  default     = true
}

variable "custom_attachment_parameters" {
  description = "A list of custom attachement parameters to use. Only used if 'use_profile_default_parameters' is set to false."
  type = list(object({
    parameter_name          = string
    parameter_display_name  = string
    parameter_type          = string
    parameter_default_value = string
    assessment_type         = string
    assessment_id           = string
  }))
  default = null
}

variable "enable_notification" {
  type        = bool
  description = "To enable notifications."
  default     = false
}

variable "notify_failed_control_ids" {
  type        = list(string)
  description = "A list of control IDs to send notifcations for when they fail."
  default     = []
}

variable "notification_threshold_limit" {
  type        = number
  description = "The threshold limit for notifications."
  default     = 14
}
