########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "scc"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "scc_profile_id" {
  type        = string
  description = "The SCC profile ID"
  default     = null
}

variable "scc_attachment_name" {
  type        = string
  description = "The name of the SCC profile attachment"
  default     = "scc-attachment-"
}

variable "scc_attachment_description" {
  type        = string
  description = "The description for the SCC profile attachment"
  default     = "SCC profile attachment"
}

variable "scc_attachment_schedule" {
  type        = string
  description = "The schedule of an attachment evaluation. Allowable values are: daily, every_7_days, every_30_days"
  default     = "daily"
}

variable "scc_attachment_status" {
  type        = string
  description = "The status of an attachment evaluation. Allowable values are: enabled, disabled"
  default     = "enabled"
}

variable "scc_scope_environment" {
  type        = string
  description = "The environment that relates to this scope"
  default     = "ibm-cloud"
}
