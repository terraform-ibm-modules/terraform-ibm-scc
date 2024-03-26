########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  description = "The id of the resource group where SCC instance is created by this module"
  value       = module.resource_group.resource_group_id
}

output "id" {
  description = "The id of the SCC instance created by this module"
  value       = module.create_scc_instance.id
}

output "guid" {
  description = "The GUID of the SCC instance created by this module"
  value       = module.create_scc_instance.guid
}

output "crn" {
  description = "The CRN of the SCC instance created by this module"
  value       = module.create_scc_instance.crn
}

output "name" {
  description = "The name of the SCC instance created by this module"
  value       = module.create_scc_instance.name
}

output "location" {
  description = "The location of the SCC instance created by this module"
  value       = module.create_scc_instance.location
}

output "plan" {
  description = "The pricing plan used to create SCC instance in this module"
  value       = module.create_scc_instance.plan
}

output "en_crn" {
  description = "The CRN of the event notification instance created in this module"
  value       = module.event_notification.crn
}

output "cos_instance_id" {
  description = "The COS instance ID created in this example"
  value       = module.cos.cos_instance_id
}

output "cos_bucket" {
  description = "The COS bucket created in this example"
  value       = module.cos.bucket_name
  depends_on  = [module.create_scc_instance]
}

# output "scc_profile_attachment_id" {
#   description = "SCC profile attachment ID"
#   value       = module.create_profile_attachment.id
# }

# output "scc_profile_attachment_parameters" {
#   description = "SCC profile attachment ID"
#   value       = module.create_profile_attachment.attachment_parameters
# }
