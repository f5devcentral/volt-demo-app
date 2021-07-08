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
}

data "kubectl_path_documents" "manifests" {
    pattern = "${path.module}/manifests/*.yaml"
    vars = {
        namespace = var.namespace,
        main_vsite = var.main_vsite,
        state_vsite = var.state_vsite,
        target_url = var.target_url,
        reg_password_b64 = var.reg_password_b64,
        reg_server_b64 = var.reg_server_b64,
        reg_username_b64 = var.reg_username_b64,
        reg_server = var.reg_server
    }
}

resource "kubectl_manifest" "documents" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
    //This provider doesn't enforce NS from kubeconfig context
    override_namespace = var.namespace
}