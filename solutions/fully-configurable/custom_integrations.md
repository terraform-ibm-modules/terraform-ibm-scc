# Configuring custom integrations

Custom provider integrations can be configured for the Security and Compliance Center instance using the `custom_integrations` input.

:information_source: If you wan't to integrate with an SCC Workload Protection instance, simply use the `existing_scc_workload_protection_instance_crn` input instead. 

## Options for custom_integrations
The `custom_integrations` input a list type input which supporting configuring multiple integrations. Each entry in the list is a map object with the following options:

- `attributes` (optional, default = `{}`): an optional map of string attributes
- `provider_name` (required): The unique provider name
- `integration_name` (required): The name to give the integration

- The following example shows how to create an integration with the Caveonix provider:

    ```
    [
      {
        provider_name    = "Caveonix"
        integration_name = "caveonix-integration"
      }
    ]
    ```

- The following example shows how to create an integration with a provider that requires attributes:

    ```
    [
      {
        provider_name    = "Sample"
        integration_name = "sample-integration"
        attributes       = {"description": "this is a sample"} 
      }
    ]
    ```
