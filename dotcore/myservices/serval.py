''' serval-dna DTN service
'''

import os

from core.service import CoreService
from core.service import ServiceManager

import nacl.hash
from nacl.encoding import HexEncoder
from nacl.bindings import crypto_sign_seed_keypair, crypto_sign_ed25519_sk_to_curve25519, crypto_scalarmult_base

servald_keyring_dump_format = '''0: type=0x04(DID)  DID="{}" Name="{}"
0: type=0x03(RHIZOME)  sec={}
0: type=0x06 (CRYPTOCOMBINED)  pub={} sec={}
'''

def generate_serval_keys(name):
    node_hash = HexEncoder.decode(nacl.hash.sha256(name))
    pk_sign_key, sk_sign_key = crypto_sign_seed_keypair(node_hash)
    sk_box_key = crypto_sign_ed25519_sk_to_curve25519(sk_sign_key)
    pk_box_key = crypto_scalarmult_base(sk_box_key)

    pub = HexEncoder.encode(pk_sign_key+pk_box_key).decode("ascii").upper()
    sec = HexEncoder.encode(sk_sign_key+sk_box_key).decode("ascii").upper()

    node_hash_rhizome = HexEncoder.decode(nacl.hash.sha256("rhizome"+name))
    rhiz = HexEncoder.encode(node_hash_rhizome).decode("ascii").upper()

    return (pub, sec, rhiz)

def generate_serval_keyring_dump(name):
    pub, sec, rhiz = generate_serval_keys(name)
    node_num = "".join(c for c in name if c.isdigit()).rjust(5, "0")

    return servald_keyring_dump_format.format(node_num, name, rhiz, pub, sec)


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
    _configs = ('serval.conf', 'keyring.dump', 'serval.sid', )
    # this controls the starting order vs other enabled services
    _startindex = 50
    # list of startup commands, also may be generated during startup
    _startup = ('bash -c "servald keyring load keyring.dump; nohup servald start foreground > serval_run.log 2>&1 &"', )
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
api.restful.users.pyserval.password=pyserval
debug.rhizome=true
'''.format(node.name)

        if filename == "keyring.dump":
            return generate_serval_keyring_dump(node.name)

        if filename == "serval.sid":
            pub = generate_serval_keys(node.name)[0]
            return pub[64:128] + "\n"


def load_services():
    ServiceManager.add(ServalService)