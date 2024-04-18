# SCC Profile Module

This module creates an SCC Profile (https://cloud.ibm.com/docs/security-compliance?topic=security-compliance-build-custom-profiles&interface=ui). A profile is a grouping of controls that can be evaluated for compliance.

The module supports the following actions:
- Create SCC Profile

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# - SCC Profile
module "create_scc_profile" {
  source           = "terraform-ibm-modules/scc/ibm//modules/profile"
  instance_id = module.create_scc_instance.guid
  controls = [
    {
      control_library_name    = "IBM Cloud Framework for Financial Services",
      control_library_version = "1.6.0"
      control_list = [
        "AC",
        "AC-1",
        "AC-1(a)",
      ]
    },
    {
      control_library_name    = "CIS IBM Cloud Foundations Benchmark",
      control_library_version = "1.0.0"
      control_list = [
        "1.16",
        "1.18",
        "1.19",
        "1.4",
      ]
    },
  ]
  profile_name        = "${var.prefix}-profile"
  profile_description = "scc-custom"
}
```

### Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - Security and Compliance Center service
        - `Administrator` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.64.1, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_scc_profile.scc_profile_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_profile) | resource |
| [ibm_scc_control_libraries.scc_control_libraries](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/scc_control_libraries) | data source |
| [ibm_scc_control_library.scc_control_library](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/scc_control_library) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_controls"></a> [controls](#input\_controls) | The list of control\_library\_ids that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items. | <pre>list(object({<br>    control_library_name    = optional(string)<br>    control_library_version = optional(string)<br>    control_list            = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_default_parameters"></a> [default\_parameters](#input\_default\_parameters) | Each assessment must be assigned a value to evaluate your resources. To customize parameters for your profile, set a new default value. Constraints: The maximum length is `512` items. The minimum length is `0` items. | <pre>list(object({<br>    assessment_type         = optional(string)<br>    assessment_id           = optional(string)<br>    parameter_name          = optional(string)<br>    parameter_default_value = optional(string)<br>    parameter_display_name  = optional(string)<br>    parameter_type          = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | The ID of the SCC instance in a particular region. | `string` | n/a | yes |
| <a name="input_profile_description"></a> [profile\_description](#input\_profile\_description) | The profile description. Constraints: The maximum length is `256` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`. | `string` | n/a | yes |
| <a name="input_profile_name"></a> [profile\_name](#input\_profile\_name) | The profile name. Constraints: The maximum length is `64` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_controls_map"></a> [controls\_map](#output\_controls\_map) | maps |
| <a name="output_profile_id"></a> [profile\_id](#output\_profile\_id) | The id of the SCC profile created by this module |
| <a name="output_scc_control_libraries"></a> [scc\_control\_libraries](#output\_scc\_control\_libraries) | The scc control libraries applied to the profile in this module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
