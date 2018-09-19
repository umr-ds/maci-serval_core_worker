from core.service import CoreService
from core.service import ServiceManager

class TcpdumpService(CoreService):
    # a unique name is required, without spaces
    _name = "tcpdump"
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
    _startup = ('''bash -c "
        for ifpath in /sys/class/net/eth*; do
            export iface=`basename $ifpath`
            nohup tcpdump -n -e -s 200 -i $iface -w $iface.pcap &> $iface.log &
            echo $! >> tcpdump.pids
        done
        "''', )
    # list of shutdown commands
    _shutdown = ('''bash -c "
        for pid in `cat tcpdump.pids`; do
            kill $pid
        done
        rm tcpdump.pids
        "''', )

def load_services():
    ServiceManager.add(TcpdumpService)