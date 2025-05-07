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
# Key Protect (instance and key)
##############################################################################

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.0.2"
  key_protect_instance_name = "${var.prefix}-key-protect"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  keys = [
    {
      key_ring_name = "${var.prefix}-scc"
      keys = [
        {
          key_name     = "${var.prefix}-scc-key"
          force_delete = true
        }
      ]
    }
  ]
}
