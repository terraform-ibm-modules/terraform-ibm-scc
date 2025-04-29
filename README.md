<!-- Update the title -->
# IBM Security and Compliance Center module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module configures an IBM Cloud Security and Compliance instance.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-scc](#terraform-ibm-scc)
* [Submodules](./modules)
    * [attachment](./modules/attachment)
* [Examples](./examples)
    * [Advanced example with CBR rules](./examples/advanced)
    * [Basic example](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-scc

### Usage
```hcl
module "create_scc_instance" {
  source            = "terraform-ibm-modules/scc/ibm"
  version           = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  instance_name     = "my-scc-instance"
  plan              = "security-compliance-center-standard-plan"
  region            = "us-south"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - Security and Compliance Center service
        - `Administrator` platform access
- IAM Services
   - Event Notifications service
        - `Manager` service access


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.77.1, <2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12.1, <1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.31.0 |
| <a name="module_crn_parser"></a> [crn\_parser](#module\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_en_crn_parser"></a> [en\_crn\_parser](#module\_en\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.en_s2s_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.scc_cos_s2s_access](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.scc_wp_s2s_access](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.scc_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_tag.access_tags](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [ibm_scc_instance_settings.scc_instance_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_instance_settings) | resource |
| [ibm_scc_provider_type_instance.custom_integrations](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_provider_type_instance) | resource |
| [ibm_scc_provider_type_instance.scc_provider_type_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_provider_type_instance) | resource |
| [time_sleep.wait_for_scc_cos_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_scc_wp_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_resource_instance.scc_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_scc_provider_types.scc_provider_types](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/scc_provider_types) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags applied to the resource instance created by the module | `list(string)` | `[]` | no |
| <a name="input_attach_wp_to_scc_instance"></a> [attach\_wp\_to\_scc\_instance](#input\_attach\_wp\_to\_scc\_instance) | When set to true, a value must be passed for the `wp_instance_crn` input variable. | `bool` | `false` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of CBR rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_cos_bucket"></a> [cos\_bucket](#input\_cos\_bucket) | The name of the Cloud Object Storage bucket to be used in SCC instance. Required when creating a new SCC instance. | `string` | `null` | no |
| <a name="input_cos_instance_crn"></a> [cos\_instance\_crn](#input\_cos\_instance\_crn) | CRN of the Cloud Object Storage to store SCC data. Required when creating a new SCC instance. | `string` | `null` | no |
| <a name="input_custom_integrations"></a> [custom\_integrations](#input\_custom\_integrations) | A list of custom provider integrations to associate with the SCC instance. | <pre>list(object({<br/>    attributes       = optional(map(string), {})<br/>    provider_name    = string<br/>    integration_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_en_instance_crn"></a> [en\_instance\_crn](#input\_en\_instance\_crn) | The CRN of Event Notifications instance to be used with SCC. Required if 'enable\_event\_notifications\_integration' is set to true. | `string` | `null` | no |
| <a name="input_en_source_description"></a> [en\_source\_description](#input\_en\_source\_description) | Optional description to give for the Event Notifications integration source. Only used if a value is passed for `en_instance_crn`. | `string` | `null` | no |
| <a name="input_en_source_name"></a> [en\_source\_name](#input\_en\_source\_name) | The source name to use for the Event Notifications integration. Required if a value is passed for `en_instance_crn`. This name must be unique per SCC instance that is integrated with the Event Notfications instance. | `string` | `"compliance"` | no |
| <a name="input_enable_event_notifications_integration"></a> [enable\_event\_notifications\_integration](#input\_enable\_event\_notifications\_integration) | Set to true to enable Event Notifications integration. If setting to true, ensure that a value is passed for the 'en\_instance\_crn' input. | `bool` | `false` | no |
| <a name="input_existing_scc_instance_crn"></a> [existing\_scc\_instance\_crn](#input\_existing\_scc\_instance\_crn) | The CRN of an existing Security and Compliance Center instance. If not supplied, a new instance will be created. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the security and compliance instance that will be provisioned by this module | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | Pricing plan to create SCC instance. Options include security-compliance-center-standard-plan or security-compliance-center-trial-plan | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where SCC instance will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the resource group to create the SCC instance | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A list of tags applied to the resources created by the module | `list(string)` | `[]` | no |
| <a name="input_skip_cos_iam_authorization_policy"></a> [skip\_cos\_iam\_authorization\_policy](#input\_skip\_cos\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this module to write access to the provided COS instance. This value will get ignored if an existing SCC instance is passed. | `bool` | `false` | no |
| <a name="input_skip_en_s2s_auth_policy"></a> [skip\_en\_s2s\_auth\_policy](#input\_skip\_en\_s2s\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this module 'Event Source Manager' access to the Event Notifications instance. This value will get ignored if an existing SCC instance is passed, or if 'enable\_event\_notifications\_integration' is false. | `bool` | `false` | no |
| <a name="input_skip_scc_wp_auth_policy"></a> [skip\_scc\_wp\_auth\_policy](#input\_skip\_scc\_wp\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this solution read access to the workload protection instance. Only used if `attach_wp_to_scc_instance` is set to true. | `bool` | `false` | no |
| <a name="input_wp_instance_crn"></a> [wp\_instance\_crn](#input\_wp\_instance\_crn) | Optionally pass the CRN of an existing SCC Workload Protection instance to attach it to the SCC instance. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The SCC account ID. |
| <a name="output_crn"></a> [crn](#output\_crn) | The CRN of the SCC instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | The GUID of the SCC instance. |
| <a name="output_id"></a> [id](#output\_id) | The id of the SCC instance. |
| <a name="output_location"></a> [location](#output\_location) | The location of the SCC instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of the SCC instance. |
| <a name="output_plan"></a> [plan](#output\_plan) | The pricing plan of the SCC instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
