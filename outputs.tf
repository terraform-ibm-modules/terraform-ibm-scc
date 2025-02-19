output "id" {
  description = "The id of the SCC instance."
  value       = local.scc_instance_crn
  # Don't return the SCC ID until it has been configured with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
}

output "guid" {
  description = "The GUID of the SCC instance."
  value       = local.scc_instance_guid
  # Don't return the SCC GUID until it has been configured with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
}

output "crn" {
  description = "The CRN of the SCC instance."
  value       = local.scc_instance_crn
  # Don't return the SCC CRN until it has been configured with COS, as it can't be used until COS integration complete
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
}

output "name" {
  description = "The name of the SCC instance."
  value       = var.existing_scc_instance_crn == null ? resource.ibm_resource_instance.scc_instance[0].name : data.ibm_resource_instance.scc_instance[0].name
}

output "location" {
  description = "The location of the SCC instance."
  value       = local.scc_instance_region
}

output "plan" {
  description = "The pricing plan of the SCC instance."
  value       = var.existing_scc_instance_crn == null ? resource.ibm_resource_instance.scc_instance[0].plan : data.ibm_resource_instance.scc_instance[0].plan
}

output "account_id" {
  description = "The SCC account ID."
  value       = local.scc_account_id
}
