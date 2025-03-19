########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
  default     = "Default"
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To not use any prefix value, you can set this value to `null` or an empty string."
  nullable    = true
  validation {
    condition = (var.prefix == null ? true :
      alltrue([
        can(regex("^[a-z]{0,1}[-a-z0-9]{0,14}[a-z0-9]{0,1}$", var.prefix)),
        length(regexall("^.*--.*", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter, contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
  }
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid value for 'provider_visibility'. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

########################################################################################################################
# SCC variables
########################################################################################################################

variable "scc_instance_name" {
  type        = string
  default     = "scc"
  description = "The name for the Security and Compliance Center instance provisioned by this solution. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "scc_region" {
  type        = string
  default     = "us-south"
  description = "The region to provision Security and Compliance Center resources in. If passing a value for `existing_scc_instance_crn`, ensure to select the region of the existing instance. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "scc_service_plan" {
  type        = string
  description = "The pricing plan to use when creating a new Security Compliance Center instance. Possible values: `security-compliance-center-standard-plan`, `security-compliance-center-trial-plan`."
  default     = "security-compliance-center-standard-plan"
  validation {
    condition     = contains(["security-compliance-center-standard-plan", "security-compliance-center-trial-plan"], var.scc_service_plan)
    error_message = "Allowed values for scc_service_plan are \"security-compliance-center-standard-plan\" and \"security-compliance-center-trial-plan\"."
  }
}

variable "scc_instance_resource_tags" {
  type        = list(string)
  description = "The list of tags to add to the Security and Compliance Center instance. Applies only if `existing_scc_instance_crn` is not provided."
  default     = []
}

variable "scc_instance_access_tags" {
  type        = list(string)
  description = "The list of access tags to add to the Security and Compliance Center instance."
  default     = []
}

variable "existing_scc_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing Security and Compliance Center instance. If not supplied, a new instance will be created."
}

variable "custom_integrations" {
  type = list(object({
    attributes       = optional(map(string), {})
    provider_name    = string
    integration_name = string
  }))
  description = "A list of custom provider integrations to associate with the Security and Compliance Center instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/fully-configurable/custom_integrations.md)."
  default     = []
  # Since this list is used in a for_each, add nullable = false to prevent error if user passes null
  nullable = false
}

variable "scopes" {
  type = map(object({
    name        = string
    description = string
    environment = optional(string, "ibm-cloud")
    properties = object({
      scope_id   = string
      scope_type = string
    })
    exclusions = optional(list(object({
      scope_id   = string
      scope_type = string
    })), [])
  }))
  default     = {}
  nullable    = false
  description = "A key map of scopes to create. The key name of each scope can be referenced in the attachments input using the 'scope_key_references' attribute. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/fully-configurable/scopes_attachments.md)."
}

variable "attachments" {
  type = list(object({
    profile_name           = string
    profile_version        = string
    attachment_name        = string
    attachment_description = string
    attachment_schedule    = string
    scope_key_references   = optional(list(string), [])
    scope_ids              = optional(list(string), [])
    notifications = object({
      enabled            = optional(bool, true)
      failed_control_ids = optional(list(string), [])
      threshold_limit    = optional(number, 10)
    })
  }))
  default     = []
  description = "A list of attachments to create. A value must be passed for 'scope_ids' (to use pre-existing scopes) and/or 'scope_key_references' (to use scopes created in the 'scopes' input). [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/fully-configurable/scopes_attachments.md)."

  validation {
    condition = alltrue([for attachments in var.attachments :
      length(attachments.scope_ids) > 0 || length(attachments.scope_key_references) > 0
    ])
    error_message = "At least one value needs to be added to the 'scope_ids' or 'scope_key_references' list inputs."
  }
  # TODO: Add validation to validate values in scope_key_references match the key identifier in the keys(var.scopes)
}

########################################################################################################################
# Workload Protection
########################################################################################################################

variable "existing_scc_workload_protection_instance_crn" {
  type        = string
  description = "The CRN of an existing Workload Protection instance to associate with the Security and Compliance Center instance."
  default     = null
}

variable "skip_scc_workload_protection_iam_auth_policy" {
  type        = bool
  default     = false
  description = "Set to `true` to skip creating an IAM authorization policy that permits the Security and Compliance Center instance to read from the Workload Protection instance. Applies only if a value is passed for `existing_scc_workload_protection_instance_crn`."
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "kms_encryption_enabled_bucket" {
  description = "Set to true to enable KMS encryption on the Object Storage bucket created for the Security and Compliance Center instance. When set to true, a value must be passed for either `existing_kms_key_crn` or `existing_kms_instance_crn` (to create a new key). Can not be set to true if passing a value for `existing_scc_instance_crn`."
  type        = bool
  default     = false

  validation {
    condition     = var.kms_encryption_enabled_bucket ? var.existing_scc_instance_crn == null : true
    error_message = "'kms_encryption_enabled_bucket' should be false if passing a value for 'existing_scc_instance_crn' as existing SCC instance will already have a bucket attached."
  }

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.kms_encryption_enabled_bucket : true
    error_message = "If passing a value for 'existing_kms_instance_crn', you should set 'kms_encryption_enabled_bucket' to true."
  }

  validation {
    condition     = var.existing_kms_key_crn != null ? var.kms_encryption_enabled_bucket : true
    error_message = "If passing a value for 'existing_kms_key_crn', you should set 'kms_encryption_enabled_bucket' to true."
  }

  validation {
    condition     = var.kms_encryption_enabled_bucket ? ((var.existing_kms_key_crn != null || var.existing_kms_instance_crn != null) ? true : false) : true
    error_message = "Either 'existing_kms_key_crn' or 'existing_kms_instance_crn' is required if 'kms_encryption_enabled_bucket' is set to true."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS instance (Hyper Protect Crypto Services or Key Protect). Used to create a new KMS key unless an existing key is passed using the `existing_scc_cos_kms_key_crn` input. If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`. A value should not be passed passing existing SCC instance using the `existing_scc_instance_crn` input."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS instance CRN in the input 'existing_kms_instance_crn' in not valid."
  }

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.existing_scc_instance_crn == null : true
    error_message = "A value should not be passed for 'existing_kms_instance_crn' when passing an existing SCC instance using the 'existing_scc_instance_crn' input."
  }
}

variable "force_delete_kms_key" {
  type        = bool
  default     = false
  description = "If creating a new KMS key, toggle whether is should be force deleted or not on undeploy."
}

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS key to use to encrypt the Security and Compliance Center Object Storage bucket. If no value is set for this variable, specify a value for either the `existing_kms_instance_crn` variable to create a key ring and key, or for the `existing_scc_cos_bucket_name` variable to use an existing bucket."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}:key:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.existing_kms_key_crn)),
      var.existing_kms_key_crn == null,
    ])
    error_message = "The provided KMS key CRN in the input 'existing_kms_key_crn' in not valid."
  }

  validation {
    condition     = var.existing_kms_key_crn != null ? var.existing_scc_instance_crn == null : true
    error_message = "A value should not be passed for 'existing_kms_key_crn' when passing an existing SCC instance using the 'existing_scc_instance_crn' input."
  }

  validation {
    condition     = var.existing_kms_key_crn != null ? var.existing_kms_instance_crn == null : true
    error_message = "A value should not be passed for 'existing_kms_instance_crn' when passing an existing key value using the 'existing_kms_key_crn' input."
  }

}

variable "kms_endpoint_type" {
  type        = string
  description = "The endpoint for communicating with the KMS instance. Possible values: `public`, `private`. Applies only if `kms_encryption_enabled_bucket` is true"
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "scc_cos_key_ring_name" {
  type        = string
  default     = "scc-cos-key-ring"
  description = "The name for the key ring created for the Security and Compliance Center Object Storage bucket key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "scc_cos_key_name" {
  type        = string
  default     = "scc-cos-key"
  description = "The name for the key created for the Security and Compliance Center Object Storage bucket. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Security and Compliance Centre instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null

  validation {
    condition     = var.ibmcloud_kms_api_key != null ? var.existing_scc_instance_crn == null : true
    error_message = "A value should not be passed for 'ibmcloud_kms_api_key' when passing an existing SCC instance using the 'existing_scc_instance_crn' input."
  }
}

########################################################################################################################
# COS variables
########################################################################################################################

variable "existing_cos_instance_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an existing Object Storage instance. Not required if passing an existing SCC instance using the `existing_scc_instance_crn` input."

  validation {
    condition     = var.existing_cos_instance_crn == null ? var.existing_scc_instance_crn != null : true
    error_message = "A value must be passed for 'existing_cos_instance_crn' when creating a new instance."
  }
}

variable "scc_cos_bucket_region" {
  type        = string
  default     = null
  description = "The region to create the Object Storage bucket used by SCC. If not provided, the region specified in the `scc_region` input will be used. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "scc_cos_bucket_name" {
  type        = string
  default     = "scc-cos-bucket"
  description = "The name for the Security and Compliance Center Object Storage bucket. Bucket names must globally unique. If `add_bucket_name_suffix` is true, a 4-character string is added to this name to  ensure it's globally unique. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Whether to add a generated 4-character suffix to the created Security and Compliance Center Object Storage bucket name. Applies only if not specifying an existing bucket. Set to `false` not to add the suffix to the bucket name in the `scc_cos_bucket_name` variable. Applies only if `existing_scc_instance_crn` is not provided."
  default     = true
}

variable "scc_cos_bucket_access_tags" {
  type        = list(string)
  default     = []
  description = "The list of access tags to add to the Security and Compliance Center Object Storage bucket. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "scc_cos_bucket_class" {
  type        = string
  default     = "smart"
  description = "The storage class of the newly provisioned Security and Compliance Center Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes). Applies only if `existing_scc_instance_crn` is not provided."
  validation {
    condition     = contains(["standard", "vault", "cold", "smart", "onerate_active"], var.scc_cos_bucket_class)
    error_message = "Allowed values for cos_bucket_class are \"standard\", \"vault\",\"cold\", \"smart\", or \"onerate_active\"."
  }
}

variable "skip_scc_cos_iam_auth_policy" {
  type        = bool
  default     = false
  description = "Set to `true` to skip creation of an IAM authorization policy that permits the Security and Compliance Center to write to the Object Storage instance created by this solution. Applies only if `existing_scc_instance_crn` is not provided."
}

variable "skip_cos_kms_iam_auth_policy" {
  type        = bool
  description = "Set to `true` to skip the creation of an IAM authorization policy that permits the Object Storage instance created to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account. Applies only if `existing_scc_instance_crn` is not provided."
  default     = false
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM Terraform provider to use to manage Object Storage buckets. Possible values: `public`, `private`m `direct`. If you specify `private`, enable virtual routing and forwarding in your account, and the Terraform runtime must have access to the the IBM Cloud private network. Applies only if `existing_scc_instance_crn` is not provided."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}

variable "existing_monitoring_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an IBM Cloud Monitoring instance to to send Security and Compliance Object Storage bucket metrics to. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration. Applies only if `existing_scc_instance_crn` is not provided."
}

########################################################################################################################
# Event Notifications
########################################################################################################################

variable "existing_event_notifications_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an Event Notification instance. Used to integrate with Security and Compliance Center."

  validation {
    condition     = var.existing_event_notifications_crn != null ? var.existing_scc_instance_crn == null : true
    error_message = "You cannot pass a value for 'existing_event_notifications_crn' when passing a value for 'existing_scc_instance_crn'. Event Notifications integration can only be configured when creating a new instance."
  }
}

variable "event_notifications_source_name" {
  type        = string
  default     = "compliance"
  description = "The source name to use for the Event Notifications integration. Required if a value is passed for `event_notifications_instance_crn`. This name must be unique per SCC instance that is integrated with the Event Notifications instance."
}

variable "event_notifications_source_description" {
  type        = string
  default     = null
  description = "Optional description to give for the Event Notifications integration source. Only used if a value is passed for `event_notifications_instance_crn`."
}

variable "scc_event_notifications_from_email" {
  type        = string
  description = "The `from` email address used in any Security and Compliance Center events coming via Event Notifications."
  default     = "compliancealert@ibm.com"
}

variable "scc_event_notifications_reply_to_email" {
  type        = string
  description = "The `reply_to` email address used in any Security and Compliance Center events coming via Event Notifications."
  default     = "no-reply@ibm.com"
}

variable "scc_event_notifications_email_list" {
  type        = list(string)
  description = "The list of email addresses to notify when Security and Compliance Center triggers an event."
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "scc_instance_cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "(Optional, list) List of context-based restrictions rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/fully-configurable/DA-cbr_rules.md)."
  default     = []
}
