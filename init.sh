set -euo pipefail

CONTAINER=${CONTAINER:-couchbase}
PASSWORD=${PASSWORD:-password}
BUCKET=${BUCKET:-server_metrics}
BUCKET_RAMSIZE=${BUCKET_RAMSIZE:-256}

echo "Waiting for Couchbase HTTP API..."
until docker exec "$CONTAINER" curl -sS http://127.0.0.1:8091/pools >/dev/null 2>&1; do sleep 1; done

echo "Attempting cluster-init (will ignore if already initialized)..."
docker exec -i "$CONTAINER" couchbase-cli cluster-init -c 127.0.0.1:8091 \
  --cluster-username Administrator --cluster-password "$PASSWORD" \
  --cluster-ramsize 512 --cluster-index-ramsize 256 \
  --services data,index,query || true

echo "Creating bucket $BUCKET (community-safe options)..."
docker exec -i "$CONTAINER" couchbase-cli bucket-create -c 127.0.0.1:8091 \
  -u Administrator -p "$PASSWORD" \
  --bucket "$BUCKET" --bucket-type couchbase --bucket-ramsize "$BUCKET_RAMSIZE" \
  --bucket-replica 0 --storage-backend couchstore --enable-flush 1 --wait || true

echo "Done."

#docker exec couchbase couchbase-cli bucket-list -c localhost:8091 -u Administrator -p password