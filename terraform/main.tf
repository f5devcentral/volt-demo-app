terraform {
  required_version = ">= 0.13"
}

module "volterra" {
  source = "./modules/volterra"

  base = var.base
  app_fqdn = var.app_fqdn
  api_url = var.api_url
  api_p12_file = var.api_p12_file
  main_site_selector = var.main_site_selector
  state_site_selector = var.state_site_selector
  cred_expiry_days = var.cred_expiry_days
}
 
module "kubectl" {
  source = "./modules/kubectl"

  reg_server = var.registry_server
  reg_password_b64 = base64encode(var.registry_password)
  reg_server_b64 = base64encode(var.registry_server)
  reg_username_b64 = base64encode(var.registry_username)

  namespace = module.volterra.namespace
  main_vsite = module.volterra.main_vsite
  state_vsite = module.volterra.state_vsite
  
  kubecfg = module.volterra.kubecfg
  target_url = module.volterra.app_url
}