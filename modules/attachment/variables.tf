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
  description = "The schedule of an attachment evaluation. Allowable values are: daily, every_7_days, every_30_days, None. If no values are passed then no schedule will be set."
  default     = null

  validation {
    condition     = contains(["daily", "every_7_days", "every_30_days", "None"], var.attachment_schedule)
    error_message = "Allowed schedule can be - daily, every_7_days, every_30_days."
  }
}

variable "scope" {
  description = "The scope payload for the SCC profile attachment."
  type = list(object({
    environment = optional(string, "ibm-cloud")
    properties = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "attachment_parameters" {
  description = "The request payload of the attachment parameters."
  type = list(object({
    parameter_name         = optional(string)
    parameter_display_name = optional(string)
    parameter_type         = optional(string)
    parameter_value        = optional(string)
    assessment_type        = optional(string)
    assessment_id          = optional(string)
  }))
}

variable "enable_notification" {
  type        = bool
  description = "To enable notifications"
  default     = false
}

variable "failed_control_ids" {
  type        = list(string)
  description = "The failed control IDs"
  default     = []
}

variable "threshold_limit" {
  type        = number
  description = "The threshold limit"
  default     = 14
}
