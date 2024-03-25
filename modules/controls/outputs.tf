########################################################################################################################
# Outputs
########################################################################################################################

output "control_library_id" {
  description = "The id of the SCC control library created by this module"
  value       = ibm_scc_control_library.scc_control_library_instance.control_library_id
}

output "controls" {
  description = "The SCC controls created in this module"
  value       = resource.ibm_scc_control_library.scc_control_library_instance.controls
}
