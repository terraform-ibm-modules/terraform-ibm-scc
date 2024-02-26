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
  description = "A list of users that you want to create on the database. Multiple blocks are allowed. The user password must be in the range of 10-32 characters. Be warned that in most case using IAM service credentials (via the var.service_credential_names) is sufficient to control access to the Etcd instance. This blocks creates native etcd database users, more info on that can be found here https://cloud.ibm.com/docs/databases-for-etcd?topic=databases-for-etcd-user-management"
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
  description = "A list of users that you want to create on the database. Multiple blocks are allowed. The user password must be in the range of 10-32 characters. Be warned that in most case using IAM service credentials (via the var.service_credential_names) is sufficient to control access to the Etcd instance. This blocks creates native etcd database users, more info on that can be found here https://cloud.ibm.com/docs/databases-for-etcd?topic=databases-for-etcd-user-management"
}
