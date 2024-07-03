moved {
  from = time_sleep.wait_for_authorization_policy
  to   = time_sleep.wait_for_scc_wp_authorization_policy
}

moved {
  from = ibm_scc_provider_type_instance.scc_provider_type_instance_instance
  to   = ibm_scc_provider_type_instance.scc_provider_type_instance
}


moved {
  from = ibm_resource_instance.scc_instance
  to   = ibm_resource_instance.scc_instance[0]
}

moved {
  from = ibm_scc_instance_settings.scc_instance_settings
  to   = ibm_scc_instance_settings.scc_instance_settings[0]
}
