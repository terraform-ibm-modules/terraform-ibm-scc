module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}-cos"
  resource_group_id = module.resource_group.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}-test1"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  storage_class        = "standard"
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.0.4"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public"
  region            = var.region
}

module "auth_policy" {
  source = "git::https://github.ibm.com/GoldenEye/s2s-auth-module?ref=1.1.1"
  service_map = [{
    source_service_name         = "compliance"
    target_service_name         = "cloud-object-storage"
    roles                       = ["Writer"]
    description                 = "Write access for SCC instance to be able to write into COS bucket"
    source_resource_instance_id = null
    target_resource_instance_id = null
    source_resource_group_id    = module.resource_group.resource_group_id
    target_resource_group_id    = module.resource_group.resource_group_id
    }
  ]
  zone_vpc_crn_list     = var.zone_vpc_crn_list
  zone_service_ref_list = var.zone_service_ref_list
  prefix                = var.prefix
}

module "create_scc_instance" {
  source            = "../.."
  instance_name     = "${var.prefix}-instance"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  cos_instance_crn  = resource.ibm_resource_instance.cos_instance.crn
  cos_bucket        = resource.ibm_cos_bucket.cos_bucket.bucket_name
  en_instance_crn   = module.event_notification.crn
}
