variable "resource_group_id" {
  type        = string
  description = "The id of the resource group to create the SCC instance"
}

variable "resource_tags" {
  type        = list(string)
  description = "A list of tags applied to the resources created by the module"
  default     = []
}

variable "existing_scc_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing Security and Compliance Center instance. If not supplied, a new instance will be created."
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags applied to the resource instance created by the module"
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Access tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "instance_name" {
  type        = string
  description = "Name of the security and compliance instance that will be provisioned by this module"
}

variable "attach_wp_to_scc_instance" {
  type        = bool
  description = "When set to true, a value must be passed for the `wp_instance_crn` input variable."
  default     = false
}

variable "wp_instance_crn" {
  type        = string
  description = "Optionally pass the CRN of an existing SCC Workload Protection instance to attach it to the SCC instance."
  default     = null
}

variable "plan" {
  description = "Pricing plan to create SCC instance. Options include security-compliance-center-standard-plan or security-compliance-center-trial-plan"
  type        = string
  default     = "security-compliance-center-standard-plan"

  validation {
    condition     = contains(["security-compliance-center-standard-plan", "security-compliance-center-trial-plan"], var.plan)
    error_message = "Invalid input, options include: \"security-compliance-center-standard-plan\", \"security-compliance-center-trial-plan\"."
  }
}

variable "region" {
  description = "Region where SCC instance will be created"
  type        = string
  default     = "us-south"

  validation {
    condition     = contains(["us-south", "ca-tor", "eu-es", "eu-de", "eu-fr2"], var.region)
    error_message = "Invalid input, options: \"us-south\", \"ca-tor\", \"eu-es\", \"eu-de\", \"eu-fr2\"."
  }
}

variable "cos_instance_crn" {
  type        = string
  default     = null
  description = "CRN of the Cloud Object Storage to store SCC data. Required when creating a new SCC instance."
}

variable "cos_bucket" {
  type        = string
  default     = null
  description = "The name of the Cloud Object Storage bucket to be used in SCC instance. Required when creating a new SCC instance."
}

variable "en_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of Event Notifications instance to be used with SCC. If no value is provided, Event Notifications will not be enabled for this SCC instance"
}

variable "skip_cos_iam_authorization_policy" {
  type        = bool
  default     = false
  description = "Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this module to write access to the provided COS instance"
}

variable "skip_scc_wp_auth_policy" {
  type        = bool
  default     = false
  description = "Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this solution read access to the workload protection instance. Only used if `attach_wp_to_scc_instance` is set to true."
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "(Optional, list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}
