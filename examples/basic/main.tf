module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "9.0.3"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cb"
}

module "create_scc_instance" {
  source                            = "../.."
  instance_name                     = "${var.prefix}-instance"
  region                            = var.region
  resource_group_id                 = module.resource_group.resource_group_id
  resource_tags                     = var.resource_tags
  access_tags                       = var.access_tags
  cos_bucket                        = module.cos.bucket_name
  cos_instance_crn                  = module.cos.cos_instance_id
  attach_wp_to_scc_instance         = false
  skip_cos_iam_authorization_policy = false
}
