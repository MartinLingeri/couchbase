#!/usr/bin/env python3
import psutil
import socket
import time
import json
from couchbase.cluster import Cluster, ClusterOptions
from couchbase.auth import PasswordAuthenticator
from couchbase.exceptions import CouchbaseException
from couchbase.options import UpsertOptions
from datetime import datetime, timedelta

USERNAME = "Administrator"
PASSWORD = "password"
BUCKET = "server_metrics"
HOST = "localhost"

def main():
    cluster = None
    try:
        cluster = Cluster(f"couchbase://{HOST}", ClusterOptions(PasswordAuthenticator(USERNAME, PASSWORD)))
        bucket = cluster.bucket(BUCKET)
        collection = bucket.default_collection()
        hostname = socket.gethostname()

        count = 0
        print("📡 Starting metric collector (1s interval, TTL=300s)...\n")
        while True:
            timestamp_ms = int(time.time() * 1000)
            timestamp_iso = datetime.utcnow().isoformat() + "Z"

            data = {
                "timestamp": timestamp_ms,
                "timestamp_str": timestamp_iso,
                "cpu_percent": psutil.cpu_percent(),
                "memory_percent": psutil.virtual_memory().percent,
                "disk_io_read_bytes": psutil.disk_io_counters().read_bytes,
                "hostname": hostname
            }

            key = f"metrics:{timestamp_ms}"
            try:
                # usar UpsertOptions(expiry=timedelta(...)) para aplicar TTL correctamente con SDK 3.x
                collection.upsert(key, data, UpsertOptions(expiry=timedelta(seconds=300)))
                count += 1
                print(f"[{count}] {timestamp_iso} | CPU={data['cpu_percent']}% | RAM={data['memory_percent']}% | key={key}")
            except CouchbaseException as e:
                print(f"❌ Error inserting document: {e}")

            time.sleep(1)

    except Exception as e:
        print(f"❌ Connection error: {e}")
    finally:
        if cluster:
            cluster.close()

if __name__ == "__main__":
    main()

