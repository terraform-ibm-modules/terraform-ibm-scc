######################################################################################################################
# Resource Group
######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

module "existing_kms_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

module "existing_kms_key_crn_parser" {
  count   = var.kms_encryption_enabled_bucket ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.scc_cos_key_ring_name, local.scc_cos_key_name)].crn
}

locals {
  prefix = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
  kms_region        = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].region : null : null
  existing_kms_guid = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_instance : null : null
  kms_service_name  = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_name : null : null
  kms_account_id    = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].account_id : null : null
  kms_key_id        = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket && length(module.existing_kms_key_crn_parser) > 0 ? module.existing_kms_key_crn_parser[0].resource : null
  scc_cos_key_ring_name                     = try("${local.prefix}-${var.scc_cos_key_ring_name}", var.scc_cos_key_ring_name)
  scc_cos_key_name                          = try("${local.prefix}-${var.scc_cos_key_name}", var.scc_cos_key_name)
  scc_cos_bucket_region                     = var.scc_cos_bucket_region != null && var.scc_cos_bucket_region != "" ? var.scc_cos_bucket_region : var.scc_region
  scc_instance_name                         = try("${local.prefix}-${var.scc_instance_name}", var.scc_instance_name)
  # Bucket name to be passed to the COS module to create a bucket
  created_scc_cos_bucket_name = try("${local.prefix}-${var.scc_cos_bucket_name}", var.scc_cos_bucket_name)
  # Final COS bucket name after being created by COS module (as it might have suffix added to it)
  scc_cos_bucket_name =  module.buckets[0].buckets[local.created_scc_cos_bucket_name].bucket_name
  create_cross_account_auth_policy = var.existing_scc_instance_crn == null ? !var.skip_cos_kms_iam_auth_policy && var.ibmcloud_kms_api_key == null ? false : (module.scc.account_id != module.existing_kms_crn_parser[0].account_id) : false
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key, if cross account KMS is passed in
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  count                       = local.create_cross_account_auth_policy ? 1 : 0
  provider                    = ibm.kms
  source_service_account      = module.scc.account_id
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the ${local.kms_service_name} key ${local.kms_key_id} from the instance ${local.existing_kms_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.existing_kms_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cos_kms_policy]
  count      = local.create_cross_account_auth_policy ? 1 : 0

  create_duration = "30s"
}

# KMS root key for SCC COS bucket
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.kms_encryption_enabled_bucket && var.existing_kms_key_crn == null ? 1 : 0
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.21.2"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = local.scc_cos_key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = local.scc_cos_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = false # TBC
        }
      ]
    }
  ]
}

#######################################################################################################################
# COS
#######################################################################################################################

module "existing_cos_crn_parser" {
  count   = var.existing_cos_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_cos_instance_crn
}

locals {
  scc_cos_kms_key_crn = var.existing_scc_instance_crn == null && var.kms_encryption_enabled_bucket ? var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.scc_cos_key_ring_name, local.scc_cos_key_name)].crn : null
  cos_instance_guid   = var.existing_scc_instance_crn == null ? var.existing_cos_instance_crn != null ? module.existing_cos_crn_parser[0].service_instance : null : null
  bucket_config = [{
    access_tags                   = var.scc_cos_bucket_access_tags
    add_bucket_name_suffix        = var.add_bucket_name_suffix
    bucket_name                   = local.created_scc_cos_bucket_name
    kms_encryption_enabled        = var.kms_encryption_enabled_bucket
    kms_guid                      = local.existing_kms_guid
    kms_key_crn                   = local.scc_cos_kms_key_crn
    skip_iam_authorization_policy = local.create_cross_account_auth_policy || var.skip_cos_kms_iam_auth_policy
    management_endpoint_type      = var.management_endpoint_type_for_bucket
    storage_class                 = var.scc_cos_bucket_class
    resource_instance_id          = var.existing_cos_instance_crn
    region_location               = local.scc_cos_bucket_region
    force_delete                  = false # TBC
    activity_tracking = {
      read_data_events  = true
      write_data_events = true
      management_events = true
    }
    metrics_monitoring = {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.existing_monitoring_crn
    }
  }]
}

# Create bucket
module "buckets" {
  providers = {
    ibm = ibm.cos
  }
  count          = var.existing_scc_instance_crn == null ? 1 : 0
  depends_on     = [time_sleep.wait_for_authorization_policy[0]]
  source         = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version        = "8.19.8"
  bucket_configs = local.bucket_config
}

#######################################################################################################################
# SCC Instance
#######################################################################################################################

module "existing_scc_crn_parser" {
  count   = var.existing_scc_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_scc_instance_crn
}

locals {
  scc_instance_region          = var.existing_scc_instance_crn == null ? var.scc_region : module.existing_scc_crn_parser[0].region
}

module "scc" {
  source                                 = "terraform-ibm-modules/scc/ibm"
  existing_scc_instance_crn              = var.existing_scc_instance_crn
  version                                = "2.0.1"
  resource_group_id                      = module.resource_group.resource_group_id
  region                                 = var.scc_region
  instance_name                          = local.scc_instance_name
  plan                                   = var.scc_service_plan
  cos_bucket                             = local.scc_cos_bucket_name
  cos_instance_crn                       = var.existing_cos_instance_crn
  enable_event_notifications_integration = var.existing_event_notifications_crn == null ? false : true
  en_instance_crn                        = var.existing_event_notifications_crn
  en_source_name                         = var.event_notifications_source_name
  en_source_description                  = var.event_notifications_source_description
  skip_cos_iam_authorization_policy      = var.skip_scc_cos_iam_auth_policy
  resource_tags                          = var.scc_instance_resource_tags
  attach_wp_to_scc_instance              = var.existing_scc_workload_protection_instance_crn != null ? true : false
  wp_instance_crn                        = var.existing_scc_workload_protection_instance_crn
  skip_scc_wp_auth_policy                = var.skip_scc_workload_protection_iam_auth_policy
  cbr_rules                              = var.scc_instance_cbr_rules
  custom_integrations                    = var.custom_integrations
  access_tags                            = var.scc_instance_access_tags
}

#######################################################################################################################
# SCC scopes
#######################################################################################################################

resource "ibm_scc_scope" "scc_scopes" {
  for_each    = var.scopes
  description = each.value.description
  environment = each.value.environment
  instance_id = module.scc.guid
  name        = each.value.name
  properties  = each.value.properties
  
  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      scope_id   = exclusions.value.scope_id
      scope_type = exclusions.value.scope_type
    }
  }
}

#######################################################################################################################
# SCC attachments
#######################################################################################################################

module "scc_attachment" {

  for_each   = {
    for index, attachment in var.attachments:
    attachment.attachment_name => attachment
  }

  source                 = "terraform-ibm-modules/scc/ibm//modules/attachment"
  version                = "2.0.1"
  profile_name           = each.value.profile_name
  profile_version        = each.value.profile_version
  scc_instance_id        = module.scc.guid
  attachment_name        = each.value.attachment_name
  attachment_description = each.value.attachment_description
  attachment_schedule    = each.value.attachment_schedule
  # lookup the scope ID created using 'scope_key_references' value
  # concat the 'scope_key_references' computed IDs with the IDs listed in the 'scope_ids' attribute
  scope_ids              = concat([for s in each.value.scope_key_references : ibm_scc_scope.scc_scopes[s].id], each.value.scope_ids)
}

#######################################################################################################################
# SCC Event Notifications Configuration
#######################################################################################################################

module "existing_en_crn_parser" {
  count   = var.existing_event_notifications_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_event_notifications_crn
}

locals {
  existing_en_guid      = var.existing_event_notifications_crn != null ? module.existing_en_crn_parser[0].service_instance : null
  existing_en_region    = var.existing_event_notifications_crn != null ? module.existing_en_crn_parser[0].region : null
}

data "ibm_en_destinations" "en_destinations" {
  provider      = ibm.en
  count         = var.existing_event_notifications_crn != null ? 1 : 0
  instance_guid = local.existing_en_guid
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5533.
resource "time_sleep" "wait_for_scc" {
  count = var.existing_event_notifications_crn != null && var.existing_scc_instance_crn == null ? 1 : 0
  depends_on = [module.scc]

  create_duration = "60s"
}

resource "ibm_en_topic" "en_topic" {
  provider      = ibm.en
  count         = var.existing_event_notifications_crn != null && var.existing_scc_instance_crn == null ? 1 : 0
  depends_on    = [time_sleep.wait_for_scc]
  instance_guid = local.existing_en_guid
  name          = "Topic for SCC instance ${module.scc.guid}"
  description   = "Topic for SCC events routing"
  sources {
    id = module.scc.crn
    rules {
      enabled           = true
      event_type_filter = "$.*"
    }
  }
}

resource "ibm_en_subscription_email" "email_subscription" {
  provider       = ibm.en
  count          = var.existing_event_notifications_crn != null && var.existing_scc_instance_crn == null && length(var.scc_event_notifications_email_list) > 0 ? 1 : 0
  instance_guid  = local.existing_en_guid
  name           = "Subscription email for SCC instance ${module.scc.guid}"
  description    = "Subscription for Security and Compliance Center Events"
  destination_id = [for s in toset(data.ibm_en_destinations.en_destinations[count.index].destinations) : s.id if s.type == "smtp_ibm"][0]
  topic_id       = ibm_en_topic.en_topic[count.index].topic_id
  attributes {
    add_notification_payload = true
    reply_to_mail            = var.scc_event_notifications_reply_to_email
    reply_to_name            = "SCC Event Notifications Bot"
    from_name                = var.scc_event_notifications_from_email
    invited                  = var.scc_event_notifications_email_list
  }
}
