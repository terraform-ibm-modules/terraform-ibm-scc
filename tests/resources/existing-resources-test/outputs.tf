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

output "scc_crn" {
  description = "Workload Protection CRN"
  value       = module.scc.crn
}

output "wp_crn" {
  description = "Workload Protection CRN"
  value       = module.scc_wp.crn
}
