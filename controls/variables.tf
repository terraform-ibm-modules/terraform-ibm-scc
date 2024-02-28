########################################################################################################################
# Input variables
########################################################################################################################

variable "instance_id" {
  type        = string
  description = "The instance_id"
}

variable "control_library_name" {
  type        = string
  description = "The control_library_name"
  default     = null
}

variable "control_library_description" {
  type        = string
  description = "The control_library_description"
  default     = null
}

variable "control_library_type" {
  type        = string
  description = "The control_library_type"
  default     = null
}

variable "version_group_label" {
  type        = string
  description = "The version_group_label"
  default     = null
}

variable "latest" {
  type        = bool
  description = "The latest"
  default     = true
}

variable "controls" {
  type = list(object({
    control_id              = optional(string)
    control_library_version = optional(string)
    control_name            = optional(string)
    control_description     = optional(string)
    control_category        = optional(string)
    control_parent          = optional(string)
    status                  = optional(string)
    control_tags            = optional(list(string))
    control_requirement     = optional(string)
    control_docs = list(object({
      control_docs_id   = optional(string)
      control_docs_type = optional(string)
    }))
    control_specifications_count = optional(string)
    control_specifications = list(object({
      control_specification_id          = optional(string)
      responsibility                    = optional(string)
      component_id                      = optional(string)
      component_name                    = optional(string)
      environment                       = optional(string)
      control_specification_description = optional(string)
      assessments_count                 = optional(string)
      assessments = list(object({
        assessment_id          = optional(string)
        assessment_method      = optional(string)
        assessment_type        = optional(string)
        assessment_description = optional(string)
        parameter_count        = optional(string)
        parameters = list(object({
          parameter_name         = optional(string)
          parameter_display_name = optional(string)
          parameter_type         = optional(string)
        }))
      }))
    }))
    profile_description = optional(string)
    profile_name        = optional(string)
    profile_type        = optional(string)
  }))
  default     = []
  description = "The list of controls that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items."
}
