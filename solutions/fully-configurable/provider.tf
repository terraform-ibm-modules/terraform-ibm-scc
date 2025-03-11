########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.scc_instance_region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_kms_api_key != null ? var.ibmcloud_kms_api_key : var.ibmcloud_api_key
  region           = local.kms_region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "cos"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.scc_cos_bucket_region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_en_region
  visibility       = var.provider_visibility
}
