output "instance_id" {
  description = "The id of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.id
}

output "instance_name" {
  description = "The name of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.name
}

output "location" {
  description = "The location of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.location
}

output "plan" {
  description = "The plan of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.plan
}
