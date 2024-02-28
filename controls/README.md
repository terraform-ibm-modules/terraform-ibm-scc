# SCC Controls Module

This module creates an SCC Control library (https://cloud.ibm.com/docs/security-compliance?topic=security-compliance-custom-library&interface=ui). A control library is a grouping of controls that are added to Security and Compliance Center.

The module supports the following actions:
- Create SCC Controls Library

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# - SCC Controls Library
module "create_scc_controls" {
  source                      = "../../controls/."
  instance_id                 = module.create_scc_instance.guid
  control_library_name        = "control_library_name"
  control_library_description = "control_library_description"
  control_library_type        = "custom"
  latest                      = true
  version_group_label         = "de38e8c4-2212-4e4b-8dcf-b021b98d8e43"
  controls = [
    {
      control_id          = "032a81ca-6ef7-4ac2-81ac-20ee4a780e3b"
      control_name        = "${var.prefix}-control-name"
      control_description = "Boundary Protection"
      control_category    = "System and Communications Protection"
      control_requirement = true
      status              = "enabled"
      control_tags        = []
      control_docs        = [{}]
      control_specifications = [
        {
          control_specification_id          = "5c7d6f88-a92f-4734-9b49-bd22b0900184"
          control_specification_description = "IBM Cloud"
          component_id                      = "iam-identity"
          component_name                    = "IAM Identity Service"
          environment                       = "ibm-cloud"
          assessments = [
            {
              assessment_type        = "automated"
              assessment_method      = "ibm-cloud-rule"
              assessment_id          = "rule-a637949b-7e51-46c4-afd4-b96619001bf1"
              assessment_description = "All assessments related to iam_identity"
              parameters = [
                {
                  parameter_name         = "session_invalidation_in_seconds"
                  parameter_display_name = "Sign out due to inactivity in seconds"
                  parameter_type         = "numeric"
                }
              ]
            }
          ]
          responsibility = "user"
        }
      ]
    }
  ]
}
```

The above will create a new scc controls library with the controls listed above and output them:
```
scc_control_library_id = "c98d8210-0d30-4a4f-967b-c4fc8c91964f"
scc_controls = tolist([
  {
    "control_category" = "System and Communications Protection"
    "control_description" = "Boundary Protection"
    "control_docs" = tolist([
      {
        "control_docs_id" = tostring(null)
        "control_docs_type" = tostring(null)
      },
    ])
    "control_id" = "032a81ca-6ef7-4ac2-81ac-20ee4a780e3b"
    "control_name" = "scc-control-name"
    "control_parent" = ""
    "control_requirement" = true
    "control_specifications" = tolist([
      {
        "assessments" = tolist([
          {
            "assessment_description" = "All assessments related to iam_identity"
            "assessment_id" = "rule-a637949b-7e51-46c4-afd4-b96619001bf1"
            "assessment_method" = "ibm-cloud-rule"
            "assessment_type" = "automated"
            "parameter_count" = 1
            "parameters" = tolist([
              {
                "parameter_display_name" = "Sign out due to inactivity in seconds"
                "parameter_name" = "session_invalidation_in_seconds"
                "parameter_type" = "numeric"
              },
            ])
          },
        ])
        "assessments_count" = 1
        "component_id" = "iam-identity"
        "component_name" = "IAM Identity Service"
        "control_specification_description" = "IBM Cloud"
        "control_specification_id" = "5c7d6f88-a92f-4734-9b49-bd22b0900184"
        "environment" = "ibm-cloud"
        "responsibility" = "user"
      },
    ])
    "control_tags" = tolist([])
    "status" = "enabled"
  },
])
```

### Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **VPC Infrastructure Services** service
        - `Editor` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.62.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_scc_control_library.scc_control_library_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.62.0/docs/resources/scc_control_library) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_library_description"></a> [control\_library\_description](#input\_control\_library\_description) | The control library description. Constraints: The maximum length is `256` characters. The minimum length is `2` characters. The value must match regular expression `/[A-Za-z0-9]+/`. | `string` | n/a | yes |
| <a name="input_control_library_name"></a> [control\_library\_name](#input\_control\_library\_name) | The control library name. Constraints: The maximum length is `64` characters. The minimum length is `2` characters. The value must match regular expression `/^[a-zA-Z0-9_\s\-]*$/`. | `string` | n/a | yes |
| <a name="input_control_library_type"></a> [control\_library\_type](#input\_control\_library\_type) | The control library type. Constraints: Allowable values are: `predefined`, `custom`. | `string` | n/a | yes |
| <a name="input_controls"></a> [controls](#input\_controls) | The list of controls that are used to create the profile. Constraints: The maximum length is `600` items. The minimum length is `0` items. Full nested schema description can be found here: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_control_library#controls. | <pre>list(object({<br>    control_id              = optional(string)<br>    control_library_version = optional(string)<br>    control_name            = optional(string)<br>    control_description     = optional(string)<br>    control_category        = optional(string)<br>    control_parent          = optional(string)<br>    status                  = optional(string)<br>    control_tags            = optional(list(string))<br>    control_requirement     = optional(string)<br>    control_docs = list(object({<br>      control_docs_id   = optional(string)<br>      control_docs_type = optional(string)<br>    }))<br>    control_specifications_count = optional(string)<br>    control_specifications = list(object({<br>      control_specification_id          = optional(string)<br>      responsibility                    = optional(string)<br>      component_id                      = optional(string)<br>      component_name                    = optional(string)<br>      environment                       = optional(string)<br>      control_specification_description = optional(string)<br>      assessments_count                 = optional(string)<br>      assessments = list(object({<br>        assessment_id          = optional(string)<br>        assessment_method      = optional(string)<br>        assessment_type        = optional(string)<br>        assessment_description = optional(string)<br>        parameter_count        = optional(string)<br>        parameters = list(object({<br>          parameter_name         = optional(string)<br>          parameter_display_name = optional(string)<br>          parameter_type         = optional(string)<br>        }))<br>      }))<br>    }))<br>    profile_description = optional(string)<br>    profile_name        = optional(string)<br>    profile_type        = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | The ID of the SCC instance in a particular region. | `string` | n/a | yes |
| <a name="input_latest"></a> [latest](#input\_latest) | (Optional) The latest version of the control library. | `bool` | `true` | no |
| <a name="input_version_group_label"></a> [version\_group\_label](#input\_version\_group\_label) | (Optional) The version group label. Constraints: The maximum length is `36` characters. The minimum length is `36` characters. The value must match regular expression `/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/`. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_library_id"></a> [control\_library\_id](#output\_control\_library\_id) | The id of the SCC control library created by this module |
| <a name="output_controls"></a> [controls](#output\_controls) | The SCC controls created in this module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
