output "id" {
  description = "SCC profile attachment ID"
  value       = resource.ibm_scc_profile_attachment.scc_profile_attachment.id
}

output "attachment_parameters" {
  description = "SCC profile attachment parameters"
  value       = resource.ibm_scc_profile_attachment.scc_profile_attachment.attachment_parameters
}
