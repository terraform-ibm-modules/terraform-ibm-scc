########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  description = "The id of the SCC instance created by this module"
  value       = ibm_scc_profile.scc_profile_instance.id
}