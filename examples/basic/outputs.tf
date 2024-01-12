########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  description = "The id of the resource group where SCC instance is created by this module"
  value       = module.resource_group.resource_group_id
}

output "instance_id" {
  description = "The id of the SCC instance created by this module"
  value       = module.create_scc_instance.id
}

output "instance_guid" {
  description = "The GUID of the SCC instance created by this module"
  value       = module.create_scc_instance.guid
}

output "instance_crn" {
  description = "The CRN of the SCC instance created by this module"
  value       = module.create_scc_instance.crn
}

output "instance_name" {
  description = "The name of the SCC instance created by this module"
  value       = module.create_scc_instance.name
}

output "instance_location" {
  description = "The location of the SCC instance created by this module"
  value       = module.create_scc_instance.location
}

output "instance_plan" {
  description = "The pricing plan used to create SCC instance in this module"
  value       = module.create_scc_instance.plan
}
