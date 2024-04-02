########################################################################################################################
# Input variables
########################################################################################################################

variable "instance_id" {
  type        = string
  description = "The ID of the SCC instance in a particular region."
}

variable "profile_name" {
  type        = string
  description = "The profile name. Constraints: The maximum length is `64` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`."
}

variable "profile_description" {
  type        = string
  description = "The profile description. Constraints: The maximum length is `256` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`."
}

variable "control_libraries" {
  type        = list(object({
    control_library_name = optional(string)
    control_library_version = optional(string)
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
  description = "The default parameters of the profile. Constraints: The maximum length is `512` items. The minimum length is `0` items."
}
