output "id" {
  description = "The id of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.id
  # Don't return the SCC ID until it has been configred with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
}

output "guid" {
  description = "The GUID of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.guid
  # Don't return the SCC GUI until it has been configred with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
}

output "crn" {
  description = "The CRN of the SCC instance created by this module"
  value       = resource.ibm_resource_instance.scc_instance.crn
  # Don't return the SCC GUI until it has been configred with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
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
