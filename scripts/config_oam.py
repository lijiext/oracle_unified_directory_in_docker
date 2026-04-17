# -------------------------------------------------------------------------
# OAM Configuration WLST Script
# This script is intended to be run using 'wlst.sh' inside the OAM container
# -------------------------------------------------------------------------

import sys

# Parameters
admin_user = 'weblogic'
admin_pwd = 'Welcome1' # Should match OAM_ADMIN_PWD in .env
admin_url = 't3://localhost:7001'

# OUD Parameters
oud_host = 'iam-oud'
oud_port = '1389'
oud_user = 'cn=Directory Manager'
oud_pwd = 'Welcome1'

def connect_to_oam():
    print 'Connecting to OAM Admin Server...'
    connect(admin_user, admin_pwd, admin_url)

def configure_oud_store():
    print 'Configuring OUD as User Identity Store...'
    # This is a conceptual example; actual OAM WLST commands depend on version
    # displayConfigInfo()
    # createIdStore(name='OUDStore', type='LDAP', ...)
    pass

def register_webgate():
    print 'Registering OHS WebGate...'
    # registerTestAgent(agentName='OHS_WebGate', agentBaseUrl='http://iam-ohs:7777', ...)
    pass

# Main
# connect_to_oam()
# configure_oud_store()
# register_webgate()
# disconnect()
