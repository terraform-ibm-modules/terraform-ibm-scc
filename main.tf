##############################################################################
# SCC module
##############################################################################

resource "ibm_resource_instance" "scc_instance" {
  name              = var.instance_name
  service           = "compliance"
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags
}

resource "ibm_scc_provider_type_instance" "scc_provider_type_instance_instance" {
  depends_on       = [ibm_iam_authorization_policy.scc_wp_s2s_access]
  count            = var.attach_wp ? 1 : 0
  instance_id      = ibm_resource_instance.scc_instance.guid
  attributes       = var.attributes
  name             = var.provider_type_instance_name
  provider_type_id = var.provider_type_id
}

resource "ibm_iam_authorization_policy" "scc_wp_s2s_access" {
  count                       = var.attach_wp ? 1 : 0
  source_service_name         = "compliance"
  source_resource_instance_id = ibm_resource_instance.scc_instance.guid
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

data "ibm_iam_account_settings" "iam_account_settings" {
}

resource "ibm_iam_authorization_policy" "scc_cos_s2s_access" {
  count                       = var.skip_cos_iam_authorization_policy ? 0 : 1
  source_service_name         = "compliance"
  source_resource_instance_id = ibm_resource_instance.scc_instance.guid
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

resource "ibm_scc_instance_settings" "scc_instance_settings" {
  instance_id = resource.ibm_resource_instance.scc_instance.guid
  event_notifications {
    instance_crn = var.en_instance_crn
  }
  object_storage {
    instance_crn = var.cos_instance_crn
    bucket       = var.cos_bucket
  }
}

locals {
  cos_instance_guid = var.cos_instance_crn != null ? element(split(":", var.cos_instance_crn), length(split(":", var.cos_instance_crn)) - 3) : null
  wp_instance_guid  = var.wp_instance_crn != null ? element(split(":", var.wp_instance_crn), length(split(":", var.wp_instance_crn)) - 3) : null
}
