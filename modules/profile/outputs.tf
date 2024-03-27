########################################################################################################################
# Outputs
########################################################################################################################

# output "profile_id" {
#   description = "The id of the SCC profile created by this module"
#   value       = ibm_scc_profile.scc_profile_instance.id
# }

output "scc_control_libraries" {
  description = "The COS bucket created in this example"
  value       = data.ibm_scc_control_libraries.scc_control_libraries.control_libraries
}
