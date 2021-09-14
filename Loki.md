# Installing Loki for logs

### loki setup steps (set up on primary)
 
* $ curl -O -L "https://github.com/grafana/loki/releases/download/v2.3.0/loki-linux-amd64.zip"

# extract the binary
* $ unzip "loki-linux-amd64.zip"

# make sure it is executable
* $ chmod a+x "loki-linux-amd64"

* wget https://raw.githubusercontent.com/grafana/loki/master/cmd/loki/loki-local-config.yaml

* Create .config file add this
 ```
 vim config.yaml
 ```
---
```
auth_enabled: false
server:
  http_listen_port: 3100
ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s
  max_transfer_retries: 0

schema_config:
  configs:
    - from: 2018-04-15
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /tmp/loki/index

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
```
# after that run the loki
### Configuration
```
 ./loki-linux-amd64 -config.file=config.yaml
```
-----
```
* after that install promtail
     wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml
```
---
### Config the Promtail 

* vim promtail-local-config.yaml and paste it
``` 
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/lib/pgsql/12/data/log/*log
```

* and after that download the zip 

     wget https://github.com/grafana/loki/releases/download/v2.3.0/promtail-linux-amd64.zip

* unzip this promtail

     unzip promtail-linux-amd64.zip

* and then run the command (opn terminal primary in both side left side run loki and right side run promtail)

    ./loki-linux-amd64 -config.file=./config.yaml 
