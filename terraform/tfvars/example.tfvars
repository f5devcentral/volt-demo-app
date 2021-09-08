base = "demo-app"
app_fqdn = "test-shop.tenant.example.com"
api_url = "https://tenant.console.ves.volterra.io/api"
api_p12_file = "./creds/tenant.api-creds.p12"

main_site_selector = ["ves.io/siteName in (ves-io-tn2-lon, ves-io-pa2-par)"]
state_site_selector = ["ves.io/siteName in (ves-io-ams9-ams)"]

registry_password = "2string:///some_b64e_password"
registry_username = "user"
registry_server = "registry.example.com"