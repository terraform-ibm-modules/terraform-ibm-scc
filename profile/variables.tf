########################################################################################################################
# Input variables
########################################################################################################################

variable "instance_id" {
  type        = string
  description = "The instance_id"
}

variable "profile_description" {
  type        = string
  description = "The profile_description"
  default     = null
}

variable "profile_name" {
  type        = string
  description = "The profile_name"
  default     = null
}

variable "profile_type" {
  type        = string
  description = "The profile_type"
  default     = null
}

variable "controls" {
  type = list(object({
    control_library_id = optional(string)
    control_id         = optional(string)
  }))
  default     = []
  description = "The list of controls that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items."
}

variable "default_parameters" {
  type = list(object({
    assessment_type         = optional(string)
    assessment_id           = optional(string)
    parameter_name          = optional(string)
    parameter_default_value = optional(string)
    parameter_display_name  = optional(string)
    parameter_type          = optional(string)
  }))
  default     = []
  description = "The default parameters of the profile. Constraints: The maximum length is `512` items. The minimum length is `0` items."
}
