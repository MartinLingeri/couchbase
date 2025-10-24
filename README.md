# Demo NoSQL — Metric Collector (Couchbase)

Pequeño servicio para recolectar métricas del sistema y guardarlas en Couchbase.

Requisitos
- Docker / Docker Compose
- Python 3 (si ejecutás el collector localmente)
- Opcional: virtualenv

Instalación rápida y arranque
1. Levantar Couchbase:
   ```bash
   docker compose up -d
   ```

2. Dar permisos ejecutables (si usás los scripts incluidos):
   ```bash
   sudo chmod +x init.sh check-ttl.sh
   ```

3. Inicializar cluster y crear bucket (si no lo automatizaste):
   ```bash
   ./init.sh
   ```

Comprobar que el bucket existe
```bash
docker exec couchbase couchbase-cli bucket-list -c localhost:8091 -u Administrator -p password
```

Ejecutar el collector (opción local)
1. Crear y activar virtualenv (recomendado):
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install --user psutil couchbase
   ```

2. Ejecutar:
   ```bash
   python3 metric_collector.py
   ```

Monitorear cantidad de documentos

En otra terminal:

```bash
./check_ttl.sh
```

Ejecutar queries N1QL

Entrar al shell:

```bash
docker exec -it couchbase cbq -u Administrator -p password
```

Luego copiar/pegar queries desde queries.sql.


Notas rápidas
- En Couchbase Community no existe `--max-ttl` por bucket; el TTL se aplica por documento (expiry) al upsert.
- Interfaz web de Couchbase: http://localhost:8091
