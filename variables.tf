variable "resource_group_id" {
  type        = string
  description = "The id of the resource group to create the SCC instance"
}

variable "resource_tags" {
  type        = list(string)
  description = "A list of tags applied to the resources created by the module"
  default     = []
}

variable "instance_name" {
  type        = string
  description = "Name of the security and compliance instance that will be provisioned by this module"
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
  description = "CRN of the Cloud Object Storage to store SCC data"
}

variable "cos_bucket" {
  type        = string
  description = "The name of the Cloud Object Storage bucket to be used in SCC instance"
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
