##############################################################################
# Input variable validations
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_new_scc_instance_cos_setting = var.existing_scc_instance_crn == null && anytrue([var.cos_bucket == null, var.cos_instance_crn == null]) ? tobool("when creating a new SCC instance, both `var.cos_instance_crn` and `var.cos_bucket` are required.") : false
  # tflint-ignore: terraform_unused_declarations
  validate_en_integration = var.en_instance_crn != null && var.en_source_name == null ? tobool("When passing a value for 'en_instance_crn', a value must also be passed for 'en_source_name'.") : false
  # tflint-ignore: terraform_unused_declarations
  validate_enabling_en = var.enable_event_notifications_integration && var.en_instance_crn == null ? tobool("If 'enable_event_notifications_integration' is true, then a value must be passed for 'en_instance_crn'.") : false
  # tflint-ignore: terraform_unused_declarations
  validate_en_integration_bool = var.en_instance_crn != null && !var.enable_event_notifications_integration ? tobool("If passing a value for 'en_instance_crn', 'enable_event_notifications_integration' must be set to true.") : false
}

##############################################################################
# Locals
##############################################################################

locals {
  service_name        = "compliance"
  scc_instance_crn    = var.existing_scc_instance_crn == null ? resource.ibm_resource_instance.scc_instance[0].crn : var.existing_scc_instance_crn
  scc_instance_guid   = module.crn_parser.service_instance
  scc_instance_region = module.crn_parser.region
  scc_account_id      = module.crn_parser.account_id
  cos_instance_guid   = var.cos_instance_crn != null ? element(split(":", var.cos_instance_crn), length(split(":", var.cos_instance_crn)) - 3) : null
  wp_instance_guid    = var.wp_instance_crn != null ? element(split(":", var.wp_instance_crn), length(split(":", var.wp_instance_crn)) - 3) : null
  lookup_providers    = var.attach_wp_to_scc_instance || length(var.custom_integrations) > 0 ? true : false
}

##############################################################################
# Lookup existing instance details
##############################################################################

data "ibm_resource_instance" "scc_instance" {
  count      = var.existing_scc_instance_crn == null ? 0 : 1
  identifier = local.scc_instance_guid
}

module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = local.scc_instance_crn
}

##############################################################################
# SCC instance
##############################################################################

resource "ibm_resource_instance" "scc_instance" {
  count             = var.existing_scc_instance_crn == null ? 1 : 0
  name              = var.instance_name
  service           = local.service_name
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags
}

# Attach access tags to SCC instance
resource "ibm_resource_tag" "access_tags" {
  resource_id = local.scc_instance_crn
  tags        = var.access_tags
  tag_type    = "access"
}

##############################################################################
# Configure COS and Event Notification integration
##############################################################################

# Create s2s auth policy for COS
resource "ibm_iam_authorization_policy" "scc_cos_s2s_access" {
  count                       = var.existing_scc_instance_crn != null || var.skip_cos_iam_authorization_policy ? 0 : 1
  source_service_name         = local.service_name
  source_resource_instance_id = local.scc_instance_guid
  roles                       = ["Writer"]

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.cos_instance_guid
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.scc_account_id
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_scc_cos_authorization_policy" {
  count           = var.existing_scc_instance_crn != null || var.skip_cos_iam_authorization_policy ? 0 : 1
  depends_on      = [ibm_iam_authorization_policy.scc_cos_s2s_access]
  create_duration = "30s"
}

# Attach a COS bucket and an event notifications instance
resource "ibm_scc_instance_settings" "scc_instance_settings" {
  depends_on  = [time_sleep.wait_for_scc_cos_authorization_policy, ibm_iam_authorization_policy.en_s2s_policy]
  count       = var.existing_scc_instance_crn == null ? 1 : 0
  instance_id = resource.ibm_resource_instance.scc_instance[0].guid
  event_notifications {
    instance_crn       = var.en_instance_crn
    source_name        = var.en_instance_crn != null ? var.en_source_name : null        # only pass source name if value being passed for 'en_instance_crn'
    source_description = var.en_instance_crn != null ? var.en_source_description : null # only pass source description if value being passed for 'en_instance_crn'
  }
  object_storage {
    instance_crn = var.cos_instance_crn
    bucket       = var.cos_bucket
  }
}

module "en_crn_parser" {
  count   = var.enable_event_notifications_integration ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.en_instance_crn
}

resource "ibm_iam_authorization_policy" "en_s2s_policy" {
  count                       = var.skip_en_s2s_auth_policy || !var.enable_event_notifications_integration || var.existing_scc_instance_crn != null ? 0 : 1
  source_service_name         = "compliance"
  source_resource_instance_id = local.scc_instance_guid
  target_service_name         = "event-notifications"
  target_resource_instance_id = module.en_crn_parser[0].service_instance
  roles                       = ["Event Source Manager"]
}

##############################################################################
# Workload Protection integration
##############################################################################

# create WP s2s auth policy
resource "ibm_iam_authorization_policy" "scc_wp_s2s_access" {
  count                       = var.attach_wp_to_scc_instance && !var.skip_scc_wp_auth_policy ? 1 : 0
  source_service_name         = local.service_name
  source_resource_instance_id = local.scc_instance_guid
  roles                       = ["Reader"]

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "sysdig-secure"
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.wp_instance_guid
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.scc_account_id
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_scc_wp_authorization_policy" {
  count           = var.attach_wp_to_scc_instance && !var.skip_scc_wp_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.scc_wp_s2s_access]
  create_duration = "30s"
}

moved {
  from = time_sleep.wait_for_scc_wp_authorization_policy
  to   = time_sleep.wait_for_scc_wp_authorization_policy[0]
}

# Lookup all supported provider types
data "ibm_scc_provider_types" "scc_provider_types" {
  count       = local.lookup_providers ? 1 : 0
  instance_id = local.scc_instance_guid
}

# loop through existing providers and find the provider type ID for WP integration
locals {
  provider_types_list = local.lookup_providers ? data.ibm_scc_provider_types.scc_provider_types[0].provider_types : []
  provider_types_map = {
    for provider_type in local.provider_types_list :
    provider_type.name => provider_type
  }
  wp_provider_type = lookup(local.provider_types_map, "workload-protection", null)
}

# Attach an SCC Workload Protection instance
resource "ibm_scc_provider_type_instance" "scc_provider_type_instance" {
  # wait until auth policy is replicated and SCC settings are configured
  depends_on       = [time_sleep.wait_for_scc_wp_authorization_policy, ibm_scc_instance_settings.scc_instance_settings]
  count            = var.attach_wp_to_scc_instance ? 1 : 0
  instance_id      = local.scc_instance_guid
  attributes       = { "wp_crn" : var.wp_instance_crn }
  name             = "workload-protection-instance"
  provider_type_id = local.wp_provider_type.id
}

##############################################################################
# Custom provider integration
#
# NOTE: To prevent a breaking change, WP integration is done in a separate
#       ibm_scc_provider_type_instance resource block above since it uses
#       count instead of for_each and existing before custom integration
#       support was added.
##############################################################################

resource "ibm_scc_provider_type_instance" "custom_integrations" {
  # wait until SCC settings are configured before adding integration
  depends_on = [ibm_scc_instance_settings.scc_instance_settings]
  for_each = {
    for i in var.custom_integrations :
    i.integration_name => i
  }
  instance_id      = local.scc_instance_guid
  attributes       = each.value.attributes
  name             = each.value.integration_name
  provider_type_id = lookup(local.provider_types_map, each.value.provider_name, null) == null ? tobool("Unable to find provider named '${each.value.provider_name}' for your instance. You can use the provider_types api to list all supported providers. See https://cloud.ibm.com/apidocs/security-compliance#list-provider-types") : lookup(local.provider_types_map, each.value.provider_name, null).id
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.30.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = local.scc_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = local.service_name
        operator = "stringEquals"
      }
    ]
  }]
}
