output "id" {
  description = "The id of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.id
}

output "guid" {
  description = "The GUID of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.guid
}

output "crn" {
  description = "The CRN of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.crn
}

output "name" {
  description = "The name of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.name
}

output "location" {
  description = "The location of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.location
}

output "plan" {
  description = "The pricing plan used to create SCC instance in this module"
  value       = resource.ibm_resource_instance.scc_instance.plan
}
