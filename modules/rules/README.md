# SCC Rules module

A module to configure SCC Rules.

Features:
- Create scc rules for an scc instance

### Usage

```hcl
module "create_scc_rules" {
  source          = "terraform-ibm-modules/scc/ibm//modules/rules"
  version         = "X.X.X"
  scc_instance_id = "123-XXX-XXX"
  rules = [
    {
      description = "new rule 1"
      version     = "1.0.0"
      import = {
        parameters = []
      }
      target = {
        service_name  = "kms"
        resource_kind = "instance"
        additional_target_attributes = [
          {
            "name" : "location",
            "operator" : "string_equals",
            "value" : "us-south"
          }
        ]
      }
    },
    {
      description = "new rule 2"
      version     = "1.0.0"
      import = {
        parameters = []
      }
      target = {
        service_name  = "kms"
        resource_kind = "instance"
        additional_target_attributes = [
          {
            "name" : "location",
            "operator" : "string_equals",
            "value" : "eu-de"
          }
        ]
      }
    }
  ]
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
| <a name="input_rules"></a> [rules](#input\_rules) | The rules to set for the SCC rules. | <pre>list(object({<br>    description = optional(string)<br>    operator    = optional(string)<br>    property    = optional(string)<br>    value       = optional(string)<br>    import = object({<br>      parameters = list(object({<br>        name         = optional(string)<br>        display_name = optional(string)<br>        description  = optional(string)<br>        type         = optional(string)<br>      }))<br>    })<br>    required_config = object({<br>      description = optional(string)<br>      operator    = optional(string)<br>      property    = optional(string)<br>      value       = optional(string)<br>      and = optional(list(<br>        object({<br>          description = optional(string)<br>          operator    = string<br>          property    = string<br>          value       = optional(string)<br>          and = optional(list(<br>            object({<br>              description = optional(string)<br>              operator    = string<br>              property    = string<br>              value       = optional(string)<br>            })<br>          ))<br>          or = optional(list(<br>            object({<br>              description = optional(string)<br>              operator    = string<br>              property    = string<br>              value       = optional(string)<br>            })<br>          ))<br>        })<br>      ))<br>      or = optional(list(<br>        object({<br>          description = optional(string)<br>          operator    = optional(string)<br>          property    = optional(string)<br>          value       = optional(string)<br>          and = optional(list(<br>            object({<br>              description = optional(string)<br>              operator    = string<br>              property    = string<br>              value       = optional(string)<br>            })<br>          ))<br>          or = optional(list(<br>            object({<br>              description = optional(string)<br>              operator    = string<br>              property    = string<br>              value       = optional(string)<br>            })<br>          ))<br>        })<br>      ))<br>    })<br>    target = object({<br>      service_name         = optional(string)<br>      service_display_name = optional(string)<br>      resource_kind        = optional(string)<br>      additional_target_attributes = list(object({<br>        name     = optional(string)<br>        operator = optional(string)<br>        value    = optional(string)<br>      }))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_rules_version"></a> [rules\_version](#input\_rules\_version) | The version number of a rule. | `string` | n/a | yes |
| <a name="input_scc_instance_id"></a> [scc\_instance\_id](#input\_scc\_instance\_id) | ID of the SCC instance in which to create the rules. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | The unique identifier of the scc\_rules created by this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
