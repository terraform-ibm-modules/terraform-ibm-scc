module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos_instance" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "7.2.2"
  cos_instance_name      = "${var.prefix}-cos19"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-b19"
}

module "create_scc_instance" {
  source                            = "../.."
  instance_name                     = "${var.prefix}-instance"
  region                            = var.region
  resource_group_id                 = module.resource_group.resource_group_id
  resource_tags                     = var.resource_tags
  cos_instance_crn                  = module.cos_instance.cos_instance_id
  cos_bucket                        = module.cos_instance.bucket_name
  skip_cos_iam_authorization_policy = false
}
