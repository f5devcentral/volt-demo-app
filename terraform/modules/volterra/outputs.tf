output "app_url" {
  description = "Domain VIP to access the web app"
  value       = format("https://%s", var.app_fqdn)
}

output "namespace" {
  description = "Namespace created for this app"
  value       = volterra_namespace.ns.name
}

output "kubecfg" {
  description = "kubeconfig file"
  value       = local_file.kubeconfig
}

