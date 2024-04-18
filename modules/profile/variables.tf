########################################################################################################################
# Input variables
########################################################################################################################

variable "instance_id" {
  type        = string
  description = "The ID of the SCC instance in a particular region."
}

variable "profile_name" {
  type        = string
  description = "The name of the profile to be created."
}

variable "profile_description" {
  type        = string
  description = "The description of the profile to be created."
}

variable "profile_version" {
  type        = string
  description = "The version status of the profile."
}

variable "controls" {
  type = list(object({
    control_library_name    = optional(string)
    control_library_version = optional(string)
    control_name_list       = optional(list(string))
  }))
  default     = []
  description = "The list of control_library_ids that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items."
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
  description = "Each assessment must be assigned a value to evaluate your resources. To customize parameters for your profile, set a new default value."
}
