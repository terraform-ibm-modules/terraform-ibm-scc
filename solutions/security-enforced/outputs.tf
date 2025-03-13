########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.scc_da.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.scc_da.resource_group_id
}

output "scc_id" {
  description = "SCC instance ID"
  value       = module.scc_da.scc_id
}

output "scc_guid" {
  description = "SCC instance guid"
  value       = module.scc_da.scc_guid
}

output "scc_crn" {
  description = "SCC instance CRN"
  value       = module.scc_da.scc_crn
}

output "scc_name" {
  description = "SCC instance name"
  value       = module.scc_da.scc_name
}

########################################################################################################################
# SCC COS
########################################################################################################################

output "scc_cos_kms_key_crn" {
  description = "SCC COS KMS Key CRN"
  value       = module.scc_da.scc_cos_kms_key_crn
}

output "scc_cos_bucket_name" {
  description = "SCC COS bucket name"
  value       = module.scc_da.scc_cos_bucket_name
}

output "scc_cos_bucket_config" {
  description = "List of buckets created"
  value       = module.scc_da.scc_cos_bucket_config
}

output "scc_cos_instance_crn" {
  description = "SCC COS instance CRN"
  value       = module.scc_da.scc_cos_instance_crn
}
