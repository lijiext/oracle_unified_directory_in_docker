# -------------------------------------------------------------------------
# OAM Domain Creation WLST Template
# -------------------------------------------------------------------------
import os

# Base OAM Template
oam_template = '/u01/oracle/oracle_common/common/templates/wls/oracle.oam_ds_template.jar'
wls_template = '/u01/oracle/wlserver/common/templates/wls/wls.jar'

# Variables from Env (Simplified for this example)
domain_name = os.getenv('OAM_DOMAIN', 'oam_domain')
domain_path = '/u01/oracle/user_projects/domains/' + domain_name
admin_user = 'weblogic'
admin_pwd = os.getenv('OAM_ADMIN_PWD', 'Welcome1')

print 'Creating domain at ' + domain_path
readTemplate(wls_template)
addTemplate(oam_template)

# Configure Admin Server
cd('/Servers/AdminServer')
set('ListenAddress', '')
set('ListenPort', 7001)

# Set Admin Password
cd('/')
cd('Security/base_domain/User/weblogic')
cmo.setPassword(admin_pwd)

# Write Domain
writeDomain(domain_path)
closeTemplate()
print 'Domain creation complete.'
exit()
