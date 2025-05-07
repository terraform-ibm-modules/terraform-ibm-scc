##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "prefix" {
  value       = var.prefix
  description = "Prefix"
}

output "region" {
  value       = var.region
  description = "region"
}

output "kms_key_crn" {
  value       = module.key_protect.keys["${var.prefix}-scc.${var.prefix}-scc-key"].crn
  description = "CRN of KMS key"
}
