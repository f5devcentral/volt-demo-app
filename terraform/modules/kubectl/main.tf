terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  config_path = var.kubecfg
}

data "kubectl_path_documents" "manifests" {
    pattern = "${path.module}/manifests/*.yaml"
    vars = {
        namespace = var.namespace,
        target_url = var.target_url,
        reg_password = var.reg_password,
        reg_server = var.reg_server,
        reg_username = var.reg_username
    }
}

resource "kubectl_manifest" "documents" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
    //This provider doesn't enforce NS from kubeconfig context
    override_namespace = var.namespace
}