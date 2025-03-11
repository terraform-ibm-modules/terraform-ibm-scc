########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "scc_id" {
  description = "SCC instance ID"
  value       = module.scc.id
}

output "scc_guid" {
  description = "SCC instance guid"
  value       = module.scc.guid
}

output "scc_crn" {
  description = "SCC instance CRN"
  value       = module.scc.crn
}

output "scc_name" {
  description = "SCC instance name"
  value       = module.scc.name
}

########################################################################################################################
# SCC COS
########################################################################################################################

output "scc_cos_kms_key_crn" {
  description = "SCC COS KMS Key CRN"
  value = local.scc_cos_kms_key_crn
}

output "scc_cos_bucket_name" {
  description = "SCC COS bucket name"
  value       = var.existing_scc_instance_crn == null ? local.scc_cos_bucket_name : null
}

output "scc_cos_bucket_config" {
  description = "List of buckets created"
  value       = var.existing_scc_instance_crn == null ? module.buckets[0].buckets[local.created_scc_cos_bucket_name] : null
}

output "scc_cos_instance_crn" {
  description = "SCC COS instance CRN"
  value       = var.existing_cos_instance_crn
}
