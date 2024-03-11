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

  validation {
    condition     = contains(["daily", "every_7_days", "every_30_days"], var.attachment_schedule)
    error_message = "Allowed schedule can be - daily, every_7_days, every_30_days."
  }
}

variable "attachment_status" {
  type        = string
  description = "The status of an attachment evaluation. Allowable values are: enabled, disabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.attachment_status)
    error_message = "Allowed status can be enabled or disabled."
  }
}

variable "scope" {
  description = "The scope payload for the SCC profile attachment."
  type = list(object({
    environment = string
    properties = list(object({
      name  = string
      value = string
    }))
  }))
}
