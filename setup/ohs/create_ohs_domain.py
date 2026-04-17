# -------------------------------------------------------------------------
# OHS Standalone Domain Creation WLST Template
# -------------------------------------------------------------------------
import os

# Base OHS Template
ohs_template = '/u01/oracle/ohs/common/templates/wls/ohs_standalone_template.jar'
wls_template = '/u01/oracle/wlserver/common/templates/wls/wls.jar'

# Variables
domain_name = 'ohs_domain'
domain_path = '/u01/oracle/user_projects/domains/' + domain_name
ohs_inst_name = os.getenv('OHS_COMPONENT_NAME', 'ohs1')
admin_pwd = os.getenv('OHS_ADMIN_PWD', 'Welcome1')

print 'Creating OHS standalone domain at ' + domain_path
readTemplate(wls_template)
addTemplate(ohs_template)

# Create OHS Instance
cd('/')
create(ohs_inst_name, 'OHS')
cd('OHS/' + ohs_inst_name)
set('ListenAddress', '')
set('ListenPort', 7777)
set('SSLListenPort', 4443)

# Set Admin Password (if any)
# cd('/Security/base_domain/User/weblogic')
# cmo.setPassword(admin_pwd)

# Write Domain
writeDomain(domain_path)
closeTemplate()
print 'OHS Domain creation complete.'
exit()
