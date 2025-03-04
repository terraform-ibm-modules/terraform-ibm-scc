variable "profile_name" {
  type        = string
  description = "Name of the SCC profile that is used for the attachment."
}

variable "profile_version" {
  type        = string
  description = "Version of the SCC profile that is used for the attachment. Defaults to the latest profile version if value is not provided."
  default     = "latest"
}

variable "scc_instance_id" {
  type        = string
  description = "GUID of the SCC instance in which to create the attachment."
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

variable "scope_ids" {
  type        = list(string)
  description = "A list of scope IDs to include in the attachment."
  nullable    = false

  validation {
    condition     = length(var.scope_ids) > 0
    error_message = "At least 1 scope ID must be passed in the 'scope_ids' input to be able to create an attachment."
  }
}

variable "use_profile_default_parameters" {
  description = "A boolean indicating whether to use the profiles default parameters. If set to false, a value must be passed for the `custom_attachment_parameters` input variable."
  type        = bool
  default     = true
}

variable "custom_attachment_parameters" {
  description = "A list of custom attachment parameters to use. Only used if 'use_profile_default_parameters' is set to false."
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
  description = "A list of control IDs to send notifications for when they fail."
  default     = []
}

variable "notification_threshold_limit" {
  type        = number
  description = "The threshold limit for notifications."
  default     = 14
}
