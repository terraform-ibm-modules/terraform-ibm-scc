# Complete example with CBR rules

A complete example that will provision the following:
- A new resource group if one is not passed in.
- A new event notification service instance.
- A new Workload Protection instance.
- A new Security and Compliance Center instance with COS bucket and event notifications enabled.
- Integration configured with the newly provisioned Workload Protection instance.
- Custom integration with the Caveonix provider.
- An SCC scope targeted to a resource group.
- An SCC attachment using the resource group scope.
