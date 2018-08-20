''' serval-dna DTN service
'''

import os

from core.service import CoreService
from core.service import ServiceManager

class ServalService(CoreService):
    '''
    Serval Delay-Tolerant Network Service
    '''
    # a unique name is required, without spaces
    _name = "Serval"
    # you can create your own group here
    _group = "Utility"
    # list of other services this service depends on
    _depends = ()
    # per-node directories
    _dirs = ()
    # generated files (without a full path this file goes in the node's dir,
    #  e.g. /tmp/pycore.12345/n1.conf/)
    _configs = ('serval.conf', )
    # this controls the starting order vs other enabled services
    _startindex = 50
    # list of startup commands, also may be generated during startup
    _startup = ('bash -c "nohup servald start foreground > serval_run.log 2>&1 &"', )
    # list of shutdown commands
    _shutdown = ('servald stop', )

    @classmethod
    def generateconfig(cls, node, filename, services):
        ''' Return a string that will be written to filename, or sent to the
            GUI for user customization.
        '''
        if filename == "serval.conf":
            return '''interfaces.0.match=*
server.motd="{}"
api.restful.users.pum.password=pum123
debug.rhizome=true
'''.format(node.name)


def load_services():
    ServiceManager.add(ServalService)