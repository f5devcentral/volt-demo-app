terraform {
  required_version = ">= 0.13"
}

module "volterra" {
  source = "./modules/volterra"

  base = var.base
  app_fqdn = var.app_fqdn
  api_url = var.api_url
  api_p12_file = var.api_p12_file
  vs_site_selector = var.vs_site_selector
}
 
module "kubectl" {
  source = "./modules/kubectl"

  reg_password = base64encode(var.registry_password)
  reg_server = base64encode(var.registry_server)
  reg_username = base64encode(var.registry_username)

  namespace = module.volterra.namespace
  kubecfg = module.volterra.kubecfg
  target_url = module.volterra.app_url
}