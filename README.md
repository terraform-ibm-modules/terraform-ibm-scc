<!-- Update the title -->
# IBM Security and Compliance Center module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module configures an IBM Cloud Security and Compliance instance.

## Known limitations
There is currently a known issue with the IBM provider (https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5131) where the provider is always trying to use the us-south endpoint when trying to configure the instance, even if the instance is not in us-south. You will see the following error on apply:
```
│ Error: UpdateSettingsWithContext failed The requested resource was not found
│ {
│     "StatusCode": 404,
│     "Headers": {
│         "Cache-Control": [
│             "no-store"
│         ],
│         "Cf-Cache-Status": [
│             "DYNAMIC"
│         ],
│         "Cf-Ray": [
│             "854ebcb0de6ebb06-MXP"
│         ],
│         "Content-Type": [
│             "application/json; charset=utf-8"
│         ],
│         "Date": [
│             "Tue, 13 Feb 2024 17:19:35 GMT"
│         ],
│         "Server": [
│             "cloudflare"
│         ],
│         "Strict-Transport-Security": [
│             "max-age=31536000; includeSubDomains"
│         ],
│         "Transaction-Id": [
│             "e2d78bad-a4c6-4dd9-8c47-ffe11088fcde"
│         ],
│         "X-Content-Type-Options": [
│             "nosniff"
│         ],
│         "X-Correlation-Id": [
│             "e2d78bad-a4c6-4dd9-8c47-ffe11088fcde"
│         ],
│         "X-Envoy-Upstream-Service-Time": [
│             "27"
│         ],
│         "X-Request-Id": [
│             "c3eaf1cb-f54b-4fcd-bda6-78f9da654e2c"
│         ]
│     },
│     "Result": {
│         "errors": [
│             {
│                 "code": "not_found",
│                 "message": "The requested resource was not found",
│                 "more_info": "https://cloud.ibm.com/apidocs/security-compliance-admin"
│             }
│         ],
│         "status_code": 404,
│         "trace": "e2d78bad-a4c6-4dd9-8c47-ffe11088fcde"
│     },
│     "RawResult": null
│ }
│
│
│   with module.create_scc_instance.ibm_scc_instance_settings.scc_instance_settings,
│   on ../../main.tf line 42, in resource "ibm_scc_instance_settings" "scc_instance_settings":
│   42: resource "ibm_scc_instance_settings" "scc_instance_settings" {
```
As a workaround, you can set the following environment variable before running apply:
```
export IBMCLOUD_SCC_API_ENDPOINT=https://REGION.compliance.cloud.ibm.com
```
where `REGION` is the value you have set for the modules `region` input variable.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-scc](#terraform-ibm-scc)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.62.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.scc_cos_s2s_access](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.scc_wp_s2s_access](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.scc_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_scc_instance_settings.scc_instance_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_instance_settings) | resource |
| [ibm_scc_provider_type_instance.scc_provider_type_instance_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_provider_type_instance) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_wp"></a> [attach\_wp](#input\_attach\_wp) | Set to true to attach a Workload Protection instance to an SCC instance | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | The attributes for connecting to the provider type instance | `map(string)` | `{}` | no |
| <a name="input_cos_bucket"></a> [cos\_bucket](#input\_cos\_bucket) | The name of the Cloud Object Storage bucket to be used in SCC instance | `string` | n/a | yes |
| <a name="input_cos_instance_crn"></a> [cos\_instance\_crn](#input\_cos\_instance\_crn) | CRN of the Cloud Object Storage to store SCC data | `string` | n/a | yes |
| <a name="input_en_instance_crn"></a> [en\_instance\_crn](#input\_en\_instance\_crn) | The CRN of Event Notifications instance to be used with SCC. If no value is provided, Event Notifications will not be enabled for this SCC instance | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the security and compliance instance that will be provisioned by this module | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | Pricing plan to create SCC instance. Options include security-compliance-center-standard-plan or security-compliance-center-trial-plan | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_provider_type_id"></a> [provider\_type\_id](#input\_provider\_type\_id) | The unique identifier of the provider type instance. | `string` | `null` | no |
| <a name="input_provider_type_instance_name"></a> [provider\_type\_instance\_name](#input\_provider\_type\_instance\_name) | The name for the provider\_type instance | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where SCC instance will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the resource group to create the SCC instance | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A list of tags applied to the resources created by the module | `list(string)` | `[]` | no |
| <a name="input_skip_cos_iam_authorization_policy"></a> [skip\_cos\_iam\_authorization\_policy](#input\_skip\_cos\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this module to write access to the provided COS instance | `bool` | `false` | no |
| <a name="input_wp_instance_crn"></a> [wp\_instance\_crn](#input\_wp\_instance\_crn) | CRN of the Workload Protection instance to attach to SCC instance | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | The CRN of the SCC instance created by this module |
| <a name="output_guid"></a> [guid](#output\_guid) | The GUID of the SCC instance created by this module |
| <a name="output_id"></a> [id](#output\_id) | The id of the SCC instance created by this module |
| <a name="output_location"></a> [location](#output\_location) | The location of the SCC instance created by this module |
| <a name="output_name"></a> [name](#output\_name) | The name of the SCC instance created by this module |
| <a name="output_plan"></a> [plan](#output\_plan) | The pricing plan used to create SCC instance in this module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
