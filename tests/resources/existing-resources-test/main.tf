##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS
##############################################################################

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.21.17"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-scc"
}

##############################################################################
# SCC
##############################################################################

module "scc" {
  source            = "terraform-ibm-modules/scc/ibm"
  version           = "2.1.15"
  instance_name     = var.prefix
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  cos_bucket        = module.cos.bucket_name
  cos_instance_crn  = module.cos.cos_instance_id
}

##############################################################################
# Workload Protection
##############################################################################

module "scc_wp" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "1.5.9"
  name              = var.prefix
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
}
