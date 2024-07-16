##############################################################################
# SCC module
##############################################################################

locals {
  parsed_existing_scc_instance_crn = var.existing_scc_instance_crn != null ? split(":", var.existing_scc_instance_crn) : []
  existing_scc_instance_guid       = length(local.parsed_existing_scc_instance_crn) > 0 ? local.parsed_existing_scc_instance_crn[7] : null
  existing_scc_instance_region     = length(local.parsed_existing_scc_instance_crn) > 0 ? local.parsed_existing_scc_instance_crn[5] : null

  scc_instance_crn    = var.existing_scc_instance_crn == null ? resource.ibm_resource_instance.scc_instance[0].crn : var.existing_scc_instance_crn
  scc_instance_guid   = var.existing_scc_instance_crn == null ? resource.ibm_resource_instance.scc_instance[0].guid : local.existing_scc_instance_guid
  scc_instance_region = var.existing_scc_instance_crn == null ? var.region : local.existing_scc_instance_region
}

data "ibm_resource_instance" "scc_instance" {
  count      = var.existing_scc_instance_crn == null ? 0 : 1
  identifier = local.scc_instance_guid
}
resource "ibm_resource_instance" "scc_instance" {
  count             = var.existing_scc_instance_crn == null ? 1 : 0
  name              = var.instance_name
  service           = "compliance"
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags
}

data "ibm_scc_provider_types" "scc_provider_types" {
  count       = var.attach_wp_to_scc_instance ? 1 : 0
  instance_id = local.scc_instance_guid
}

locals {
  provider_types_list = var.attach_wp_to_scc_instance ? data.ibm_scc_provider_types.scc_provider_types[0].provider_types : []

  provider_types_map = {
    for provider_type in local.provider_types_list :
    provider_type.name => provider_type
  }

  provider_type = lookup(local.provider_types_map, "workload-protection", null)
}

resource "ibm_iam_authorization_policy" "scc_cos_s2s_access" {
  count                       = var.skip_cos_iam_authorization_policy ? 0 : 1
  source_service_name         = "compliance"
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
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_scc_cos_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.scc_cos_s2s_access]

  create_duration = "30s"
}

locals {
  valiate_new_scc_instance_cos_configuration = var.existing_scc_instance_crn == null && (var.cos_instance_crn == null || var.cos_bucket == null)
  # tflint-ignore: terraform_unused_declarations
  valiate_new_scc_instance_cos_configuration_msg = local.valiate_new_scc_instance_cos_configuration ? tobool("`var.cos_instance_crn` and `var.cos_bucket` are required when creating a new SCC instance") : true
  
  validate_scc_cos_configuaration = var.configure_cos_instance && (var.cos_instance_crn == null || var.cos_bucket == null)
  # tflint-ignore: terraform_unused_declarations
  validate_scc_cos_configuaration_msg = local.validate_scc_cos_configuaration ? tobool("`var.cos_instance_crn` and `var.cos_bucket` are required when `var.configure_cos_instance` is true") : true

  # tflint-ignore: terraform_unused_declarations
  validate_scc_en_configuaration = var.configure_en_instance && var.en_instance_crn == null ? tobool("`var.en_instance_crn` is required when `var.configure_en_instance` is true") : true
}

# attach a COS bucket and an event notifications instance
resource "ibm_scc_instance_settings" "scc_instance_settings" {
  count       = var.existing_scc_instance_crn == null || var.configure_cos_instance || var.configure_en_instance ? 1 : 0
  depends_on  = [time_sleep.wait_for_scc_cos_authorization_policy]
  instance_id = local.scc_instance_guid

  event_notifications {
    instance_crn = var.configure_en_instance ? var.en_instance_crn : null
  }
  object_storage {
    instance_crn = var.configure_cos_instance ? var.cos_instance_crn : null
    bucket       = var.configure_cos_instance ? var.cos_bucket : null
  }
}


resource "ibm_iam_authorization_policy" "scc_wp_s2s_access" {
  count                       = var.attach_wp_to_scc_instance && !var.skip_scc_wp_auth_policy ? 1 : 0
  source_service_name         = "compliance"
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
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_scc_wp_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.scc_wp_s2s_access]

  create_duration = "30s"
}

# attach an SCC Workload Protection instance
resource "ibm_scc_provider_type_instance" "scc_provider_type_instance" {
  depends_on       = [time_sleep.wait_for_scc_wp_authorization_policy, ibm_scc_instance_settings.scc_instance_settings]
  count            = var.attach_wp_to_scc_instance ? 1 : 0
  instance_id      = local.scc_instance_guid
  attributes       = { "wp_crn" : var.wp_instance_crn }
  name             = "workload-protection-instance"
  provider_type_id = local.provider_type.id
}

data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {
  cos_instance_guid = var.cos_instance_crn != null ? element(split(":", var.cos_instance_crn), length(split(":", var.cos_instance_crn)) - 3) : null
  wp_instance_guid  = var.wp_instance_crn != null ? element(split(":", var.wp_instance_crn), length(split(":", var.wp_instance_crn)) - 3) : null
}

##############################################################################
# Context Based Restrictions
##############################################################################
module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.23.0"
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
        value    = "compliance"
        operator = "stringEquals"
      }
    ]
  }]
}
