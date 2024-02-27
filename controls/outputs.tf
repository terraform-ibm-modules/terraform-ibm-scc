########################################################################################################################
# Outputs
########################################################################################################################

output "control_library_id" {
  description = "The id of the SCC profile created by this module"
  value       = ibm_scc_control_library.scc_control_library_instance.control_library_id
}

output "controls" {
  description = "The scc controls created in this example"
  value       = resource.ibm_scc_control_library.scc_control_library_instance.controls
}
