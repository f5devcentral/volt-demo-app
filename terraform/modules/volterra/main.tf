terraform {
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.8.1"
    }
  }
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_url
}

resource "volterra_namespace" "ns" {
  name = var.base
}

//Consistency issue with provider response for NS resource
//https://github.com/volterraedge/terraform-provider-volterra/issues/53
resource "time_sleep" "ns_wait" {
  depends_on = [volterra_namespace.ns]
  create_duration = "5s"
}

resource "volterra_virtual_site" "main" {
  name      = format("%s-vs", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [time_sleep.ns_wait]

  site_selector {
    expressions = var.main_site_selector
  }
  site_type = "REGIONAL_EDGE"
}

resource "volterra_virtual_site" "state" {
  name      = format("%s-state", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [time_sleep.ns_wait]

  site_selector {
    expressions = var.state_site_selector
  }
  site_type = "REGIONAL_EDGE"
}

resource "volterra_virtual_k8s" "vk8s" {
  name      = format("%s-vk8s", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [time_sleep.ns_wait]

  vsite_refs {
    name      = volterra_virtual_site.main.name
    namespace = volterra_namespace.ns.name
  }
  vsite_refs {
    name      = volterra_virtual_site.state.name
    namespace = volterra_namespace.ns.name
  }
}

//Consistency issue with vk8s resource response
//https://github.com/volterraedge/terraform-provider-volterra/issues/54
resource "time_sleep" "vk8s_wait" {
  depends_on = [volterra_virtual_k8s.vk8s]
  create_duration = "120s"
}

resource "volterra_api_credential" "vk8s_cred" {
  name      = format("%s-api-cred", var.base)
  api_credential_type = "KUBE_CONFIG"
  virtual_k8s_namespace = volterra_namespace.ns.name
  virtual_k8s_name = volterra_virtual_k8s.vk8s.name
  expiry_days = var.cred_expiry_days
  depends_on = [time_sleep.vk8s_wait]
}

resource "local_file" "kubeconfig" {
    content = base64decode(volterra_api_credential.vk8s_cred.data)
    filename = format("%s/../../creds/%s", path.module, format("%s-vk8s.yaml", terraform.workspace))
}

resource "volterra_app_type" "at" {
  // This naming simplifies the 'mesh' cards
  name      = var.base
  namespace = "shared"
  features {
    type = "BUSINESS_LOGIC_MARKUP"
  }
  features {
    type = "USER_BEHAVIOR_ANALYSIS"
  }
  features {
    type = "PER_REQ_ANOMALY_DETECTION"
  }
  features {
    type = "TIMESERIES_ANOMALY_DETECTION"
  }
  business_logic_markup_setting {
    enable = true
  }
}

resource "volterra_origin_pool" "frontend" {
  name                   = format("%s-frontend", var.base)
  namespace              = volterra_namespace.ns.name
  depends_on             = [time_sleep.ns_wait]
  description            = format("Origin pool pointing to frontend k8s service running in main-vsite")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("frontend.%s", volterra_namespace.ns.name)
      site_locator {
        virtual_site {
          name      = volterra_virtual_site.main.name
          namespace = volterra_namespace.ns.name
        }
      }
    }
  }
  port               = 80
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_origin_pool" "redis" {
  name                   = format("%s-redis", var.base)
  namespace              = volterra_namespace.ns.name
  depends_on             = [time_sleep.ns_wait]
  description            = format("Origin pool pointing to redis k8s service running in state-vsite")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("redis-cart.%s", volterra_namespace.ns.name)
      site_locator {
        virtual_site {
          name      = volterra_virtual_site.state.name
          namespace = volterra_namespace.ns.name
        }
      }
    }
  }
  port               = 6379
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_waf" "waf" {
  name        = format("%s-waf", var.base)
  description = format("WAF in block mode for %s", var.base)
  namespace   = volterra_namespace.ns.name
  depends_on = [time_sleep.ns_wait]
  app_profile {
    cms       = []
    language  = []
    webserver = []
  }
  mode = "BLOCK"
  lifecycle {
    ignore_changes = [
      app_profile
    ]
  }
}

resource "volterra_http_loadbalancer" "frontend" {
  name                            = format("%s-fe", var.base)
  namespace                       = volterra_namespace.ns.name
  depends_on                      = [time_sleep.ns_wait]
  description                     = format("HTTPS loadbalancer object for %s origin server", var.base)
  domains                         = [var.app_fqdn]
  advertise_on_public_default_vip = true
  labels                          = { "ves.io/app_type" = volterra_app_type.at.name }
  default_route_pools {
    pool {
      name      = volterra_origin_pool.frontend.name
      namespace = volterra_namespace.ns.name
    }
  }
  https_auto_cert {
    add_hsts      = false
    http_redirect = true
    no_mtls       = true
  }
  waf {
    name      = volterra_waf.waf.name
    namespace = volterra_namespace.ns.name
  }
  disable_waf                     = false
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true
}

resource "volterra_tcp_loadbalancer" "redis" {
  name                            = format("%s-redis", var.base)
  namespace                       = volterra_namespace.ns.name
  depends_on                      = [time_sleep.ns_wait]
  description                     = format("TCP loadbalancer object for %s redis service", var.base)
  domains                         = ["redis-cart.internal"]
  dns_volterra_managed            = false
  listen_port                     = 6379
  labels                          = { "ves.io/app_type" = volterra_app_type.at.name }
  origin_pools_weights {
    pool {
      name      = volterra_origin_pool.redis.name
      namespace = volterra_namespace.ns.name
    }
  }
  advertise_custom {
    advertise_where {
      vk8s_service {
        virtual_site {
          name      = volterra_virtual_site.main.name
          namespace = volterra_namespace.ns.name
        }
      }
    port = 6379
    }
  }
  retract_cluster = true
  hash_policy_choice_round_robin = true
}