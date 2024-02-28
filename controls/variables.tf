########################################################################################################################
# Input variables
########################################################################################################################

variable "instance_id" {
  type        = string
  description = "The ID of the SCC instance in a particular region."
}

variable "control_library_name" {
  type        = string
  description = "The control library name. Constraints: The maximum length is `64` characters. The minimum length is `2` characters. The value must match regular expression `/^[a-zA-Z0-9_\\s\\-]*$/`."
}

variable "control_library_description" {
  type        = string
  description = "The control library description. Constraints: The maximum length is `256` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`."
}

variable "control_library_type" {
  type        = string
  description = "The control library type. Constraints: Allowable values are: `predefined`, `custom`."
}

variable "version_group_label" {
  type        = string
  description = "(Optional) The version group label. Constraints: The maximum length is `36` characters. The minimum length is `36` characters. The value must match regular expression `/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/`."
}

variable "latest" {
  type        = bool
  description = "(Optional) The latest version of the control library."
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
  description = "The list of controls that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items. Full nested schema description can be found here: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_control_library#controls."
}
