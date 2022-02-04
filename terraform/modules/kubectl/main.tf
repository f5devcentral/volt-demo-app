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

data "kubectl_path_documents" "secret" {
    pattern = "${path.module}/manifests/secret.yaml"
    vars = {
        namespace = var.namespace,
        main_vsite = var.main_vsite,
        state_vsite = var.state_vsite,
        reg_password_b64 = var.reg_password_b64,
        reg_server_b64 = var.reg_server_b64,
        reg_username_b64 = var.reg_username_b64,
        reg_server = var.reg_server
    }
}

data "kubectl_path_documents" "manifests" {
    pattern = "${path.module}/manifests/manifest*.yaml"
    vars = {
        namespace = var.namespace,
        utility_namespace = var.utility_namespace,
        main_vsite = var.main_vsite,
        state_vsite = var.state_vsite,
        utility_vsite = var.utility_vsite,
        target_url = var.target_url,
        reg_server = var.reg_server
    }
}

resource "kubectl_manifest" "secret" {
    count     = length(data.kubectl_path_documents.secret.documents)
    yaml_body = element(data.kubectl_path_documents.secret.documents, count.index)
    override_namespace = var.namespace
}

resource "kubectl_manifest" "manifests" {
    depends_on = [kubectl_manifest.secret]
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
    override_namespace = var.namespace
}