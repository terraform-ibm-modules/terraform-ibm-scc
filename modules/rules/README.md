# SCC Profile Attachment module

A module to configure an SCC Profile Attachment.

Features:
- Create an attachment using a profile ID
- Use the default profile parameters, or pass a custom parameter list
- Configure a scan schedule for the attachment
- Configure notifications for the attachment

### Usage

```hcl
module "create_scc_profile_attachment " {
  source                         = "terraform-ibm-modules/scc/ibm//modules/attachment"
  ibmcloud_api_key               = "XXXXXXXXXX" # pragma: allowlist secret
  scc_instance_id                = "57b7ac52-e837-484c-aa07-e3c2db815c44" # replace with the ID of your SCC instance
  profile_id                     = "f54b4962-06c6-46bb-bb04-396d9fa9bd60" # select the ID of the profile you want to use
  use_profile_default_parameters = true # if setting this to false, custom parameters must be passed using the 'custom_attachment_parameters' variable
  attachment_name                = "My attachment"
  attachment_description         = "My attachment description"
  attachment_schedule            = "daily"
  # Configure the scope for the attachment - below scope will scan the whole account
  scope {
    environment   = "ibm-cloud"
    properties {
        name                = "scope-type"
        value               = "account"
    }
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.63.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_scc_rule.scc_rule_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_rule) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rules"></a> [rules](#input\_rules) | The rules to set for the SCC rules. | <pre>list(object({<br>    description = string<br>    version     = string<br>    import = object({<br>      parameters = list(object({<br>        name         = optional(string)<br>        display_name = optional(string)<br>        description  = optional(string)<br>        type         = optional(string)<br>      }))<br>    })<br>    # required_config = object({<br>    #   description = string<br>    #   value = list(object({}))<br>    # })<br>    target = object({<br>      service_name         = optional(string)<br>      service_display_name = optional(string)<br>      resource_kind        = optional(string)<br>      additional_target_attributes = list(object({<br>        name     = optional(string)<br>        operator = optional(string)<br>        value    = optional(string)<br>      }))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_scc_instance_id"></a> [scc\_instance\_id](#input\_scc\_instance\_id) | ID of the SCC instance in which to create the attachment. | `string` | `"57b7ac52-e837-484c-aa07-e3c2db815c44"` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
