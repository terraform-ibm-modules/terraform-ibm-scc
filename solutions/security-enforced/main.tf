#######################################################################################################################
# Wrapper around fully-configurable variation
#######################################################################################################################

module "scc_da" {
  source                                        = "../fully-configurable"
  ibmcloud_api_key                              = var.ibmcloud_api_key
  existing_resource_group_name                  = var.existing_resource_group_name
  prefix                                        = var.prefix
  provider_visibility                           = "private"
  scc_instance_name                             = var.scc_instance_name
  scc_region                                    = var.scc_region
  scc_service_plan                              = var.scc_service_plan
  scc_instance_resource_tags                    = var.scc_instance_resource_tags
  scc_instance_access_tags                      = var.scc_instance_access_tags
  existing_scc_instance_crn                     = var.existing_scc_instance_crn
  custom_integrations                           = var.custom_integrations
  scopes                                        = var.scopes
  attachments                                   = var.attachments
  existing_scc_workload_protection_instance_crn = var.existing_scc_workload_protection_instance_crn
  skip_scc_workload_protection_iam_auth_policy  = var.skip_scc_workload_protection_iam_auth_policy
  kms_encryption_enabled_bucket                 = true
  existing_kms_instance_crn                     = var.existing_kms_instance_crn
  force_delete_kms_key                          = var.force_delete_kms_key
  existing_kms_key_crn                          = var.existing_kms_key_crn
  kms_endpoint_type                             = "private"
  scc_cos_key_ring_name                         = var.scc_cos_key_ring_name
  scc_cos_key_name                              = var.scc_cos_key_name
  ibmcloud_kms_api_key                          = var.ibmcloud_kms_api_key
  existing_cos_instance_crn                     = var.existing_cos_instance_crn
  scc_cos_bucket_region                         = var.scc_cos_bucket_region
  scc_cos_bucket_name                           = var.scc_cos_bucket_name
  add_bucket_name_suffix                        = var.add_bucket_name_suffix
  scc_cos_bucket_access_tags                    = var.scc_cos_bucket_access_tags
  scc_cos_bucket_class                          = var.scc_cos_bucket_class
  skip_scc_cos_iam_auth_policy                  = var.skip_scc_cos_iam_auth_policy
  skip_cos_kms_iam_auth_policy                  = var.skip_cos_kms_iam_auth_policy
  management_endpoint_type_for_bucket           = "private"
  existing_monitoring_crn                       = var.existing_monitoring_crn
  existing_event_notifications_crn              = var.existing_event_notifications_crn
  event_notifications_source_name               = var.event_notifications_source_name
  event_notifications_source_description        = var.event_notifications_source_description
  scc_event_notifications_from_email            = var.scc_event_notifications_from_email
  scc_event_notifications_reply_to_email        = var.scc_event_notifications_reply_to_email
  scc_event_notifications_email_list            = var.scc_event_notifications_email_list
  scc_instance_cbr_rules                        = var.scc_instance_cbr_rules
}
