from __future__ import print_function
import socket
import struct
import subprocess
import json
from time import time
from os import path
from sys import stdin


def ip2long(ip):
    return struct.unpack("!L", socket.inet_aton(ip))[0]


def long2ip(ip):
    return socket.inet_ntoa(struct.pack("!L", ip))


def diff(x, y):
    return list(set(x) - set(y))


query = json.loads(stdin.read())
project = query['project']
cluster_name = query['cluster']
location = query['location']
cluster_identifier = "-".join([cluster_name, location])

all_ranges = []
index = ip2long("172.16.0.0")
max_long = ip2long("172.16.2.255")
available_ranges = list(all_ranges)
lock_file = "/tmp/master_ipv4_cidr_block.lock"

while index < max_long:
    all_ranges.append(long2ip(index) + "/28")
    index += 16

parsed = json.loads(
    subprocess.check_output(
        ["gcloud container clusters list --format json 2>/dev/null"],
        env={"CLOUDSDK_CORE_PROJECT": project},
        shell=True
    )
)

# First, check whether the cluster already exists. If it does, then use the value returned from the API.
existing_cluster = list(filter(lambda x: "-".join([x['name'], x['location']]) == cluster_identifier, parsed))
existing_cluster = existing_cluster[0] if len(existing_cluster) > 0 else None

if existing_cluster:
    print(json.dumps({"cidr_block": existing_cluster['privateClusterConfig']['masterIpv4CidrBlock']}))
    exit(0)

already_assigned_ranges = list(
    filter(
        None,
        map(
            lambda x: x['privateClusterConfig']['masterIpv4CidrBlock'] if 'privateClusterConfig' in x else None,
            parsed
        )
    )
)
available_ranges = diff(all_ranges, already_assigned_ranges)
cidr_block = None
locked_ranges = []

# Perform super basic locking. This is an attempt to prevent the parallel creation of clusters from being assigned
# the same IP range.
# The timeout is set to 10 minutes, because it shouldn't take longer than that to create the cluster, at which point
# it would be included in the `gcloud` command earlier.
if path.isfile(lock_file) and time() - path.getmtime(lock_file) < 600:
    with open(lock_file) as fp:
        try:
            locked_ranges = json.load(fp)
        except ValueError:
            locked_ranges = []

        available_ranges = diff(available_ranges, locked_ranges)


available_ranges = sorted(available_ranges, key=lambda x: ip2long(str(x).split("/")[0]))
cidr_block = available_ranges[0]

if not cidr_block:
    print("No CIDR blocks available for assignment.")
    exit(1)

locked_ranges.append(cidr_block)
json.dump(locked_ranges, open(lock_file, mode='w'))

print(json.dumps({"cidr_block": cidr_block}))
