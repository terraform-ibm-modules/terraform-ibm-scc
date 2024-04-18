########################################################################################################################
# Outputs
########################################################################################################################

output "profile_id" {
  description = "The id of the SCC profile created by this module"
  value       = ibm_scc_profile.scc_profile_instance.profile_id
}

output "scc_control_libraries" {
  description = "The scc control libraries applied to the profile in this module"
  value = [
    for control_lib in local.control_libraries : {
      name           = control_lib.control_library_name
      id             = control_lib.id
      version        = control_lib.control_library_version
      controls_count = control_lib.controls_count
    }
  ]
}
