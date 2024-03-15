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
        name      = "scope-type"
        value     = "account"
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
| [ibm_scc_profile_attachment.scc_profile_attachment](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_profile_attachment) | resource |
| [ibm_scc_profile.scc_profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/scc_profile) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attachment_description"></a> [attachment\_description](#input\_attachment\_description) | The description for the SCC profile attachment. | `string` | n/a | yes |
| <a name="input_attachment_name"></a> [attachment\_name](#input\_attachment\_name) | The name to give to SCC profile attachment. | `string` | n/a | yes |
| <a name="input_attachment_schedule"></a> [attachment\_schedule](#input\_attachment\_schedule) | The schedule of an attachment. Allowable values are: daily, every\_7\_days, every\_30\_days, none. | `string` | `"daily"` | no |
| <a name="input_custom_attachment_parameters"></a> [custom\_attachment\_parameters](#input\_custom\_attachment\_parameters) | A list of custom attachement parameters to use. Only used if 'use\_profile\_default\_parameters' is set to false. | <pre>list(object({<br>    parameter_name          = string<br>    parameter_display_name  = string<br>    parameter_type          = string<br>    parameter_default_value = string<br>    assessment_type         = string<br>    assessment_id           = string<br>  }))</pre> | `null` | no |
| <a name="input_enable_notification"></a> [enable\_notification](#input\_enable\_notification) | To enable notifications. | `bool` | `false` | no |
| <a name="input_notification_threshold_limit"></a> [notification\_threshold\_limit](#input\_notification\_threshold\_limit) | The threshold limit for notifications. | `number` | `14` | no |
| <a name="input_notify_failed_control_ids"></a> [notify\_failed\_control\_ids](#input\_notify\_failed\_control\_ids) | A list of control IDs to send notifcations for when they fail. | `list(string)` | `[]` | no |
| <a name="input_profile_id"></a> [profile\_id](#input\_profile\_id) | ID of the profile you wish to use for the attachment. | `string` | n/a | yes |
| <a name="input_scc_instance_id"></a> [scc\_instance\_id](#input\_scc\_instance\_id) | ID of the SCC instance in which to create the attachment. | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope to set for the SCC profile attachment. | <pre>list(object({<br>    environment = optional(string, "ibm-cloud")<br>    properties = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_use_profile_default_parameters"></a> [use\_profile\_default\_parameters](#input\_use\_profile\_default\_parameters) | A boolean indicating whether to use the profiles default parameters. If set to false, a value must be passed for the `custum_attachment_parameters` input variable. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_attachment_parameters"></a> [attachment\_parameters](#output\_attachment\_parameters) | SCC profile attachment parameters |
| <a name="output_id"></a> [id](#output\_id) | SCC profile attachment ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
