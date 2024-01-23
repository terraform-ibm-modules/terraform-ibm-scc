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
