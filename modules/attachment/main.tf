##############################################################################
# Variable validation
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_attachment_parameters = var.custom_attachment_parameters == null && !var.use_profile_default_parameters ? tobool("A value must be passed for 'custom_attachment_parameters' if 'use_profile_default_parameters' is set to false.") : true
}

##############################################################################
# SCC profile attachment
##############################################################################

data "ibm_scc_profiles" "scc_profiles" {
  instance_id = var.scc_instance_id
}

locals {
  # Get profile and its various versions by name matching that provided in var.profile_name
  relevant_profile_versions = [
    for profile in data.ibm_scc_profiles.scc_profiles.profiles : profile if profile.profile_name == var.profile_name
  ]

  # Sort profile versions from lowest to highest
  sorted_profile_versions = sort(local.relevant_profile_versions[*].profile_version)

  # Create sorted list of profiles, ordered from lowest to highest profile version
  sorted_list = flatten(
    [
      for version in local.sorted_profile_versions :
      [
        for profile in local.relevant_profile_versions :
        profile if version == profile.profile_version
      ]
    ]
  )

  validate_profile_name = length(local.sorted_list) == 0 ? tobool("Could not find a valid profile name ${var.profile_name}") : true

  # Retrieve profile with the latest version by getting last element in sorted list
  latest_profile = local.validate_profile_name ? local.sorted_list[length(local.sorted_list) - 1] : null

  profile_map = var.profile_version == "latest" ? {
    (var.profile_name) = local.latest_profile
    } : {
    for profile in data.ibm_scc_profiles.scc_profiles.profiles :
    var.profile_name => profile if profile.profile_name == var.profile_name && profile.profile_version == var.profile_version
  }

  # tflint-ignore: terraform_unused_declarations
  validate_profile_version = lookup(local.profile_map, var.profile_name, null) == null ? tobool("Could not find a valid profile name ${var.profile_name} and matching version ${var.profile_version}") : true

  profile = local.validate_profile_version ? local.profile_map[var.profile_name] : null
}

data "ibm_scc_profile" "scc_profile" {
  instance_id = var.scc_instance_id
  profile_id  = local.profile.id
}

locals {
  attachment_parameters = var.use_profile_default_parameters ? data.ibm_scc_profile.scc_profile.default_parameters : var.custom_attachment_parameters
}

# Create the attachment
resource "ibm_scc_profile_attachment" "profile_attachment" {
  profile_id  = local.profile.id
  instance_id = var.scc_instance_id
  name        = var.attachment_name
  description = var.attachment_description
  # To workaround https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5207 we set schedule to 'daily' here even though 'none' was passed in.
  # The end result will be the schedule being set to none since the 'status' option below sets that.
  schedule = var.attachment_schedule == "none" ? "daily" : var.attachment_schedule
  status   = var.attachment_schedule == "none" ? "disabled" : "enabled"

  dynamic "scope" {
    for_each = var.scope_ids
    content {
      id = scope.value
    }
  }

  dynamic "attachment_parameters" {
    for_each = local.attachment_parameters
    content {
      parameter_name         = attachment_parameters.value["parameter_name"]
      parameter_display_name = attachment_parameters.value["parameter_display_name"]
      parameter_type         = attachment_parameters.value["parameter_type"]
      parameter_value        = attachment_parameters.value["parameter_default_value"]
      assessment_type        = attachment_parameters.value["assessment_type"]
      assessment_id          = attachment_parameters.value["assessment_id"]
    }
  }

  notifications {
    enabled = var.enable_notification
    controls {
      failed_control_ids = var.notify_failed_control_ids
      threshold_limit    = var.notification_threshold_limit
    }
  }
}
