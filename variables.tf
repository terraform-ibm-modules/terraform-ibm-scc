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
