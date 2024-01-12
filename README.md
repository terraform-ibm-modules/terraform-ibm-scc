<!-- Update the title -->
# IBM Security and Compliance Center module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module configures an IBM Cloud Security and Compliance instance.
Currently, this module lacks the capability to configure an SCC instance with a Cloud Object Storage bucket. However, there is a provider issue to track this addition - https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4881


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-scc](#terraform-ibm-scc)
* [Examples](./examples)
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

  source            = "terraform-ibm-modules/scc/ibm"
  version           = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  instance_name     = "my-scc-instance"
  plan              = "security-compliance-center-standard-plan"
  region            = "us-south"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
You need the following permissions to run this module.

- Account Management
    - Security and Compliance Center service
        - `Administrator` access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.61.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.scc_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the security and compliance instance that will be provisioned by this module | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | Pricing plan to create SCC instance. Options include security-compliance-center-standard-plan or security-compliance-center-trial-plan | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where SCC instance will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the resource group to create the SCC instance | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A list of tags applied to the resources created by the module | `list(string)` | `[]` | no |

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
