output "rule_ids" {
  description = "The ids for the rules created by this module."
  value = [
    for rule in resource.ibm_scc_rule.scc_rule_instance : {
      rule_id   = rule.rule_id
    }
  ]
}
