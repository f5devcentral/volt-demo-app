terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  config_path = var.kubecfg.filename
  apply_retry_count = 2
}

data "kubectl_path_documents" "manifests" {
    pattern = "${path.module}/manifests/*.yaml"
    vars = {
        namespace = var.namespace,
        main_vsite = var.main_vsite,
        state_vsite = var.state_vsite,
        reg_password_b64 = var.reg_password_b64,
        reg_server_b64 = var.reg_server_b64,
        reg_username_b64 = var.reg_username_b64,
        reg_server = var.reg_server
        injected_js = trimspace(var.injected_js)
    }
}

resource "kubectl_manifest" "manifests" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
    override_namespace = var.namespace
}