# Creating Scopes and Attachments

It is possible to create multiple scopes and multiple attachments in a Security and Compliance Centre instance using the `scopes` and `attachments` inputs.

## Scopes
The `scopes` input can be used to create multiple scopes, which can then be used in 1 or more attachments. The input is an object map type, and each scope must be created using a map key identifier with the following attributes:

- `name` (required): The name of the scope
- `description` (required): The description of the scope
- `environment` (optional, default = "ibm-cloud"): The scope environment
- `properties` (required): A map of properties containing:
    - `scope_type` (required): The type of target the scope will cover. Acceptable values are: `account`, `account.resource_group`, `enterprise.account_group`, `enterprise`
    - `scope_id` (required): The ID of the target defined in `scope_type`
- `exclusions` (optional): A list exclusions in the format of a map of strings containing:
    - `scope_type` (required): The type of target the exclusion will cover. Acceptable values are: `account`, `account.resource_group`, `enterprise.account_group`, `enterprise`
    - `scope_id` (required): The ID of the exclusion target defined in `scope_type`

- The following example shows how to create a scope for the full account:
  ```
  {
    all = {
      name = "Full account"
      description = "Scope to scan the whole account"
      environment = "ibm-cloud"
      properties = {
        scope_id   = "abac0df06b644a9cabc6e44f55b3880e"
        scope_type = "account"
      }
    }
  }
  ```
  - The key identifier for above example is `all`. This can be referenced when creating attachments using the `scope_key_references` attribute of the [attachments](#attachments) input.

- The following example shows how to exclude a resource group from the scope:
  ```
  {
    exclude = {
      name = "Exclude Default resource group"
      description = "Scope to exclude the Default resource group"
      environment = "ibm-cloud"
      properties = {
        scope_id   = "abac0df06b644a9cabc6e44f55b3880e"
        scope_type = "account"
      }
      exclusions = [{
        scope_id   = "07b6d899988a4631841e3bc7d0307dcf"
        scope_type = "account.resource_group"
      }]
    }
  }
  ```
  - The key identifier for above example is `exclude`. This can be referenced when creating attachments using the `scope_key_references` attribute of the [attachments](#attachments) input.

## Attachments
The `attachments` input can be used to create multiple attachments using either pre-existing scopes, or scopes that were created with the [scopes](#scopes) input. The input type is a list of objects with the following attributes:

- `profile_name` (required): The name of an existing profile to use for the attachments creation.
- `profile_version` (required): The version to use of the profile specified in `profile_name`. Supports the string `latest` to use the latest version.
- `attachment_name` (required): The name to give the attachment.
- `attachment_description` (required): The description of the attachment.
- `attachment_schedule` (required): The attachment schedule. Acceptable values are: `daily`, `every_7_days`, `every_30_days`, `none`.
- `scope_key_references` (optional): A list of key identifier strings for scopes that were created using the [attachments](#attachments) input that you want to include in the attachment. To use a pre-existing scope, you can use the `scope_ids` option below. Both inputs cannot be an empty list.
- `scope_ids` (optional): A list of pre-existing scope IDs to include in the attachment. To use a scope that was created with the `scopes input variable, use the `scope_key_references` option above. Both inputs cannot be an empty list.
- `notifications` (optional): A map of notification settings containing:
    - `enabled` (optional, default: `true`): true of false to enable or disable notifications
    - `failed_control_ids` (optional, default: `[]`): A list of failed control IDs to be notified of
    - `threshold_limit` (optional, default: `10`): The threshold limit

- The following example shows how to create an attachment with a daily schedule using a scope that was created with the first `scopes` example above:
  ```
  [{
    profile_name = "SOC 2"
    profile_version = "latest"
    attachment_name = "SOC 2 full account"
    attachment_description = "SOC 2 full account"
    attachment_schedule = "daily"
    scope_key_references = ["all"]
    notifications = {
      enabled = true
      failed_control_ids = ["c51c5094-6f6b-4fee-b0f6-ad51ca68e18a"]
      threshold_limit = 10
    }
  }]
  ```

- The following example shows how to create an attachment with a 30 day schedule using a scope IDs that already exist:
  ```
  [{
    profile_name = "SOC 2"
    profile_version = "latest"
    attachment_name = "SOC 2"
    attachment_description = "SOC 2"
    attachment_schedule = "every_30_days"
    scope_ids = ["e59990c6-ddec-49b7-9656-0dcfcdcaa6cf", "e8be9035-6c43-4035-b8a3-37ef63786e5c"]
    notifications = {
      enabled = true
      failed_control_ids = ["c51c5094-6f6b-4fee-b0f6-ad51ca68e18a"]
      threshold_limit = 10
    }
  }]
  ```
