# Cloud automation for Security and Compliance Center (Fully configurable)

## Prerequisites
- An existing resource group
- An existing COS instance
- An existing KMS instance (or key) if you wan't to encrypt the COS bucket created for use with SCC

This solution supports provisioning and configuring the following infrastructure:
- A Security and Compliance Center instance.
- A Cloud Object Storage bucket which is required to store Security and Compliance Center data.
- Security and Compliance Center scopes and attachments.
- Integrations with Workload Protection and other custom providers

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![scc-deployable-architecture](../../reference-architecture/scc.svg)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.77.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | terraform-ibm-modules/cos/ibm//modules/buckets | 8.21.17 |
| <a name="module_existing_cos_crn_parser"></a> [existing\_cos\_crn\_parser](#module\_existing\_cos\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_en_crn_parser"></a> [existing\_en\_crn\_parser](#module\_existing\_en\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_kms_crn_parser"></a> [existing\_kms\_crn\_parser](#module\_existing\_kms\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_kms_key_crn_parser"></a> [existing\_kms\_key\_crn\_parser](#module\_existing\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_scc_crn_parser"></a> [existing\_scc\_crn\_parser](#module\_existing\_scc\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/kms-all-inclusive/ibm | 5.0.1 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.0 |
| <a name="module_scc"></a> [scc](#module\_scc) | ../.. | n/a |
| <a name="module_scc_attachment"></a> [scc\_attachment](#module\_scc\_attachment) | ../../modules/attachment | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_en_subscription_email.email_subscription](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.77.1/docs/resources/en_subscription_email) | resource |
| [ibm_en_topic.en_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.77.1/docs/resources/en_topic) | resource |
| [ibm_iam_authorization_policy.cos_kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.77.1/docs/resources/iam_authorization_policy) | resource |
| [ibm_scc_scope.scc_scopes](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.77.1/docs/resources/scc_scope) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/sleep) | resource |
| [time_sleep.wait_for_scc](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/sleep) | resource |
| [ibm_en_destinations.en_destinations](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.77.1/docs/data-sources/en_destinations) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_bucket_name_suffix"></a> [add\_bucket\_name\_suffix](#input\_add\_bucket\_name\_suffix) | Whether to add a generated 4-character suffix to the created Security and Compliance Center Object Storage bucket name. Applies only if not specifying an existing bucket. Set to `false` not to add the suffix to the bucket name in the `scc_cos_bucket_name` variable. Applies only if `existing_scc_instance_crn` is not provided. | `bool` | `true` | no |
| <a name="input_attachments"></a> [attachments](#input\_attachments) | A list of attachments to create. A value must be passed for 'scope\_ids' (to use pre-existing scopes) and/or 'scope\_key\_references' (to use scopes created in the 'scopes' input). [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc/tree/main/solutions/fully-configurable/scopes_attachments.md). | <pre>list(object({<br/>    profile_name           = string<br/>    profile_version        = string<br/>    attachment_name        = string<br/>    attachment_description = string<br/>    attachment_schedule    = string<br/>    scope_key_references   = optional(list(string), [])<br/>    scope_ids              = optional(list(string), [])<br/>    notifications = object({<br/>      enabled            = optional(bool, true)<br/>      failed_control_ids = optional(list(string), [])<br/>      threshold_limit    = optional(number, 10)<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_integrations"></a> [custom\_integrations](#input\_custom\_integrations) | A list of custom provider integrations to associate with the Security and Compliance Center instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc/tree/main/solutions/fully-configurable/custom_integrations.md). | <pre>list(object({<br/>    attributes       = optional(map(string), {})<br/>    provider_name    = string<br/>    integration_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_event_notifications_source_description"></a> [event\_notifications\_source\_description](#input\_event\_notifications\_source\_description) | Optional description to give for the Event Notifications integration source. Only used if a value is passed for `event_notifications_instance_crn`. | `string` | `null` | no |
| <a name="input_event_notifications_source_name"></a> [event\_notifications\_source\_name](#input\_event\_notifications\_source\_name) | The source name to use for the Event Notifications integration. Required if a value is passed for `event_notifications_instance_crn`. This name must be unique per SCC instance that is integrated with the Event Notifications instance. | `string` | `"compliance"` | no |
| <a name="input_existing_cos_instance_crn"></a> [existing\_cos\_instance\_crn](#input\_existing\_cos\_instance\_crn) | The CRN of an existing Object Storage instance. Not required if passing an existing SCC instance using the `existing_scc_instance_crn` input. | `string` | `null` | no |
| <a name="input_existing_event_notifications_crn"></a> [existing\_event\_notifications\_crn](#input\_existing\_event\_notifications\_crn) | The CRN of an Event Notification instance. Used to integrate with Security and Compliance Center. | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of an existing KMS instance (Hyper Protect Crypto Services or Key Protect). Used to create a new KMS key unless an existing key is passed using the `existing_scc_cos_kms_key_crn` input. If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`. A value should not be passed passing existing SCC instance using the `existing_scc_instance_crn` input. | `string` | `null` | no |
| <a name="input_existing_kms_key_crn"></a> [existing\_kms\_key\_crn](#input\_existing\_kms\_key\_crn) | The CRN of an existing KMS key to use to encrypt the Security and Compliance Center Object Storage bucket. If no value is set for this variable, specify a value for either the `existing_kms_instance_crn` variable to create a key ring and key, or for the `existing_scc_cos_bucket_name` variable to use an existing bucket. | `string` | `null` | no |
| <a name="input_existing_monitoring_crn"></a> [existing\_monitoring\_crn](#input\_existing\_monitoring\_crn) | The CRN of an IBM Cloud Monitoring instance to to send Security and Compliance Object Storage bucket metrics to. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision resource in. | `string` | `"Default"` | no |
| <a name="input_existing_scc_instance_crn"></a> [existing\_scc\_instance\_crn](#input\_existing\_scc\_instance\_crn) | The CRN of an existing Security and Compliance Center instance. If not supplied, a new instance will be created. | `string` | `null` | no |
| <a name="input_existing_scc_workload_protection_instance_crn"></a> [existing\_scc\_workload\_protection\_instance\_crn](#input\_existing\_scc\_workload\_protection\_instance\_crn) | The CRN of an existing Workload Protection instance to associate with the Security and Compliance Center instance. | `string` | `null` | no |
| <a name="input_force_delete_kms_key"></a> [force\_delete\_kms\_key](#input\_force\_delete\_kms\_key) | If creating a new KMS key, toggle whether is should be force deleted or not on undeploy. | `bool` | `false` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key used to provision resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_kms_api_key"></a> [ibmcloud\_kms\_api\_key](#input\_ibmcloud\_kms\_api\_key) | The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud\_api\_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Security and Compliance Centre instance. Leave this input empty if the same account owns both instances. | `string` | `null` | no |
| <a name="input_kms_encryption_enabled_bucket"></a> [kms\_encryption\_enabled\_bucket](#input\_kms\_encryption\_enabled\_bucket) | Set to true to enable KMS encryption on the Object Storage bucket created for the Security and Compliance Center instance. When set to true, a value must be passed for either `existing_kms_key_crn` or `existing_kms_instance_crn` (to create a new key). Can not be set to true if passing a value for `existing_scc_instance_crn`. | `bool` | `false` | no |
| <a name="input_kms_endpoint_type"></a> [kms\_endpoint\_type](#input\_kms\_endpoint\_type) | The endpoint for communicating with the KMS instance. Possible values: `public`, `private`. Applies only if `kms_encryption_enabled_bucket` is true | `string` | `"private"` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM Terraform provider to use to manage Object Storage buckets. Possible values: `public`, `private`m `direct`. If you specify `private`, enable virtual routing and forwarding in your account, and the Terraform runtime must have access to the the IBM Cloud private network. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"private"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To not use any prefix value, you can set this value to `null` or an empty string. | `string` | n/a | yes |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_scc_cos_bucket_access_tags"></a> [scc\_cos\_bucket\_access\_tags](#input\_scc\_cos\_bucket\_access\_tags) | The list of access tags to add to the Security and Compliance Center Object Storage bucket. Applies only if `existing_scc_instance_crn` is not provided. | `list(string)` | `[]` | no |
| <a name="input_scc_cos_bucket_class"></a> [scc\_cos\_bucket\_class](#input\_scc\_cos\_bucket\_class) | The storage class of the newly provisioned Security and Compliance Center Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes). Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"smart"` | no |
| <a name="input_scc_cos_bucket_name"></a> [scc\_cos\_bucket\_name](#input\_scc\_cos\_bucket\_name) | The name for the Security and Compliance Center Object Storage bucket. Bucket names must globally unique. If `add_bucket_name_suffix` is true, a 4-character string is added to this name to  ensure it's globally unique. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"scc-cos-bucket"` | no |
| <a name="input_scc_cos_bucket_region"></a> [scc\_cos\_bucket\_region](#input\_scc\_cos\_bucket\_region) | The region to create the Object Storage bucket used by SCC. If not provided, the region specified in the `scc_region` input will be used. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `null` | no |
| <a name="input_scc_cos_key_name"></a> [scc\_cos\_key\_name](#input\_scc\_cos\_key\_name) | The name for the key created for the Security and Compliance Center Object Storage bucket. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"scc-cos-key"` | no |
| <a name="input_scc_cos_key_ring_name"></a> [scc\_cos\_key\_ring\_name](#input\_scc\_cos\_key\_ring\_name) | The name for the key ring created for the Security and Compliance Center Object Storage bucket key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"scc-cos-key-ring"` | no |
| <a name="input_scc_event_notifications_email_list"></a> [scc\_event\_notifications\_email\_list](#input\_scc\_event\_notifications\_email\_list) | The list of email addresses to notify when Security and Compliance Center triggers an event. | `list(string)` | `[]` | no |
| <a name="input_scc_event_notifications_from_email"></a> [scc\_event\_notifications\_from\_email](#input\_scc\_event\_notifications\_from\_email) | The `from` email address used in any Security and Compliance Center events coming via Event Notifications. | `string` | `"compliancealert@ibm.com"` | no |
| <a name="input_scc_event_notifications_reply_to_email"></a> [scc\_event\_notifications\_reply\_to\_email](#input\_scc\_event\_notifications\_reply\_to\_email) | The `reply_to` email address used in any Security and Compliance Center events coming via Event Notifications. | `string` | `"no-reply@ibm.com"` | no |
| <a name="input_scc_instance_access_tags"></a> [scc\_instance\_access\_tags](#input\_scc\_instance\_access\_tags) | The list of access tags to add to the Security and Compliance Center instance. | `list(string)` | `[]` | no |
| <a name="input_scc_instance_cbr_rules"></a> [scc\_instance\_cbr\_rules](#input\_scc\_instance\_cbr\_rules) | (Optional, list) List of context-based restrictions rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc/tree/main/solutions/fully-configurable/DA-cbr_rules.md). | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_scc_instance_name"></a> [scc\_instance\_name](#input\_scc\_instance\_name) | The name for the Security and Compliance Center instance provisioned by this solution. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"scc"` | no |
| <a name="input_scc_instance_resource_tags"></a> [scc\_instance\_resource\_tags](#input\_scc\_instance\_resource\_tags) | The list of tags to add to the Security and Compliance Center instance. Applies only if `existing_scc_instance_crn` is not provided. | `list(string)` | `[]` | no |
| <a name="input_scc_region"></a> [scc\_region](#input\_scc\_region) | The region to provision Security and Compliance Center resources in. If passing a value for `existing_scc_instance_crn`, ensure to select the region of the existing instance. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"us-south"` | no |
| <a name="input_scc_service_plan"></a> [scc\_service\_plan](#input\_scc\_service\_plan) | The pricing plan to use when creating a new Security Compliance Center instance. Possible values: `security-compliance-center-standard-plan`, `security-compliance-center-trial-plan`. | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | A key map of scopes to create. The key name of each scope can be referenced in the attachments input using the 'scope\_key\_references' attribute. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc/tree/main/solutions/fully-configurable/scopes_attachments.md). | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    environment = optional(string, "ibm-cloud")<br/>    properties = object({<br/>      scope_id   = string<br/>      scope_type = string<br/>    })<br/>    exclusions = optional(list(object({<br/>      scope_id   = string<br/>      scope_type = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_skip_cos_kms_iam_auth_policy"></a> [skip\_cos\_kms\_iam\_auth\_policy](#input\_skip\_cos\_kms\_iam\_auth\_policy) | Set to `true` to skip the creation of an IAM authorization policy that permits the Object Storage instance created to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account. Applies only if `existing_scc_instance_crn` is not provided. | `bool` | `false` | no |
| <a name="input_skip_scc_cos_iam_auth_policy"></a> [skip\_scc\_cos\_iam\_auth\_policy](#input\_skip\_scc\_cos\_iam\_auth\_policy) | Set to `true` to skip creation of an IAM authorization policy that permits the Security and Compliance Center to write to the Object Storage instance created by this solution. Applies only if `existing_scc_instance_crn` is not provided. | `bool` | `false` | no |
| <a name="input_skip_scc_workload_protection_iam_auth_policy"></a> [skip\_scc\_workload\_protection\_iam\_auth\_policy](#input\_skip\_scc\_workload\_protection\_iam\_auth\_policy) | Set to `true` to skip creating an IAM authorization policy that permits the Security and Compliance Center instance to read from the Workload Protection instance. Applies only if a value is passed for `existing_scc_workload_protection_instance_crn`. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_scc_cos_bucket_config"></a> [scc\_cos\_bucket\_config](#output\_scc\_cos\_bucket\_config) | List of buckets created |
| <a name="output_scc_cos_bucket_name"></a> [scc\_cos\_bucket\_name](#output\_scc\_cos\_bucket\_name) | SCC COS bucket name |
| <a name="output_scc_cos_instance_crn"></a> [scc\_cos\_instance\_crn](#output\_scc\_cos\_instance\_crn) | SCC COS instance CRN |
| <a name="output_scc_cos_kms_key_crn"></a> [scc\_cos\_kms\_key\_crn](#output\_scc\_cos\_kms\_key\_crn) | SCC COS KMS Key CRN |
| <a name="output_scc_crn"></a> [scc\_crn](#output\_scc\_crn) | SCC instance CRN |
| <a name="output_scc_guid"></a> [scc\_guid](#output\_scc\_guid) | SCC instance guid |
| <a name="output_scc_id"></a> [scc\_id](#output\_scc\_id) | SCC instance ID |
| <a name="output_scc_name"></a> [scc\_name](#output\_scc\_name) | SCC instance name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
