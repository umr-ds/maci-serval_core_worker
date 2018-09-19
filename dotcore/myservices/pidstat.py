import os

from core.service import CoreService
from core.service import ServiceManager

class PidstatService(CoreService):
    # a unique name is required, without spaces
    _name = "pidstat"
    # you can create your own group here
    _group = "Logging"
    # list of other services this service depends on
    _depends = ()
    # per-node directories
    _dirs = ()
    # generated files (without a full path this file goes in the node's dir,
    #  e.g. /tmp/pycore.12345/n1.conf/)
    _configs = ()
    # this controls the starting order vs other enabled services
    _startindex = 50
    # list of startup commands, also may be generated during startup
    _startup = ('bash -c "nohup pidstat -drush -p ALL 1 > pidstat 2> pidstat.log" &', )
    # list of shutdown commands
    _shutdown = ()

def load_services():
    ServiceManager.add(PidstatService)