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
  description = "Pricing plan to create SCC instance. Options include Standard or Trial"
  type        = string
}

variable "region" {
  description = "Region where SCC instance will be created"
  type        = string
}
