-- 1️⃣ Últimos 10 documentos
SELECT * FROM `server_metrics`
ORDER BY timestamp DESC
LIMIT 10;

-- 2️⃣ Agregaciones de últimos 2 minutos
SELECT 
  AVG(cpu_percent) AS avg_cpu,
  MAX(cpu_percent) AS max_cpu,
  MIN(cpu_percent) AS min_cpu,
  COUNT(*) AS total
FROM `server_metrics`
WHERE timestamp > MILLIS(NOW_STR()) - 120000;

-- 3️⃣ Promedios agrupados por minuto
SELECT 
  DATE_TRUNC_STR(MILLIS_TO_STR(timestamp), 'minute') AS minute,
  AVG(cpu_percent) AS avg_cpu,
  AVG(memory_percent) AS avg_mem
FROM `server_metrics`
GROUP BY DATE_TRUNC_STR(MILLIS_TO_STR(timestamp), 'minute')
ORDER BY minute DESC
LIMIT 5;

-- 4️⃣ Filtrar por CPU > 50%
SELECT timestamp_str, cpu_percent, memory_percent
FROM `server_metrics`
WHERE cpu_percent > 50
ORDER BY timestamp DESC
LIMIT 10;
