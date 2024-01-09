########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  description = "The id of the resource group where SCC instance is created by this module"
  value       = module.resource_group.resource_group_id
}

output "scc_instance_details" {
  description = "Details of SCC instance created by this module"
  value       = module.create_scc_instance
}
