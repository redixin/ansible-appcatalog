DOMAIN = "{{catalog_domain}}"
BASE_URL = "{{catalog_protocol}}://%s" % DOMAIN
OPENID_RETURN_URL = BASE_URL + "/auth/process"
GLARE_URL = "{{glare_protocol}}://{{glare_domain}}"
DEBUG = {{catalog_debug | default("False")}}
