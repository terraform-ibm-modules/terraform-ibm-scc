output "rule_ids" {
  description = "SCC profile attachment parameters"
  value       = [for rule in resource.ibm_scc_rule.scc_rule_instance : rule.rule_id]
}
