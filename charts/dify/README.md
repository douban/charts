# dify

This helm chart is based on docker-compose provided by dify

this helm is distributed with `Apache License 2.0`

## install

create your own values file , save as `values.yaml`

```yaml
global:
  host: "mydify.example.com"
  enableTLS: false

  image:
    # Set to the latest version of dify
    # Check the version here: https://github.com/langgenius/dify/releases
    # If not set, Using the default value in Chart.yaml
    tag: "0.6.3"
  extraBackendEnvs:
  - name: SECRET_KEY
    value: "generate your own one"
  - name: LOG_LEVEL
    value: "DEBUG"
  - name: VECTOR_STORE
    value: "milvus"

ingress:
  enabled: true
  className: "nginx"

minio:
  embedded: true
```

```sh
# install it
helm repo add douban https://douban.github.io/charts/
helm upgrade dify douban/dify -f values.yaml --install --debug
```

**Must** run db migration after installation, or the instance would not work.

```sh
# run migration
kubectl exec -it dify-pod-name -- flask db upgrade
```

## Upgrade

To upgrade app, change the value of `global.image.tag` to the desired version

```yaml
global:
  image:
    tag: "0.6.3"
```

Then upgrade the app with helm command

```sh
helm upgrade dify douban/dify -f values.yaml --debug
```

**Must** run db migration after upgrade.

```sh
# run migration
kubectl exec -it dify-pod-name -- flask db upgrade
```

## Production use checklist

The minimal configure provided above is sufficient for experiment but **without any persistance**, all your data would be lost if you restarted the postgresql pod or minio pod!!

You **must do**  the following extra work before put it into production!!

### Protect Sensitive info with secret

Environment variable like `SECRET_KEY` could be harmful if leaked, it is adviced to protect them using secret or csi volume.

The example of using secret is like

```yaml
global:
  extraBackendEnvs:
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify
        key: SECRET_KEY
```

Read more: <https://kubernetes.io/docs/concepts/security/secrets-good-practices/>

### External postgresql

1. set the `postgresql.embedded` to `false`
2. inject connection info with `global.extraBackendEnvs`

```yaml
global:
  extraBackendEnvs:
  - name: DB_USERNAME
    value: "foo"
  # it is adviced to use secret to manage you sensitive info including password
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify
        key: DB_PASSWORD
  - name: DB_HOST
    value: "my_pg.xxx"
  - name: DB_PORT
    value: "1234"
  - name: DB_DATABASE
    value: dify
```

### External redis

1. set the `redis.embedded` to `false`
2. inject connection info with `global.extraBackendEnvs`

```yaml
global:
  extraBackendEnvs:
  - name: REDIS_HOST
    value: "foo"
  - name: REDIS_PORT
    value: "6379"
  - name: REDIS_DB
    value: "1"
  # it is adviced to use secret to manage you sensitive info including password
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify
        key: REDIS_PASSWORD
  - name: CELERY_BROKER_URL
    valueFrom:
      secretKeyRef:
        name: dify
        key: CELERY_BROKER_URL
```

### External bucket

#### Amazon S3

1. set the `minio.embedded` to `false`
2. inject connection info with `global.extraBackendEnvs`

```yaml
global:
  storageType: "s3"
  extraBackendEnvs:
  - name: S3_ENDPOINT
    value: "https://my-endpoint.s3.com"
  - name: S3_BUCKET_NAME
    value: "dify"
  # it is adviced to use secret to manage you sensitive info including password
  - name: S3_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: dify
        key: S3_ACCESS_KEY
  - name: S3_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify
        key: S3_SECRET_KEY
```

#### Google Cloud Storage

1. set the `minio.embedded` to `false`
2. inject connection info with `global.extraBackendEnvs`

```yaml
global:
  storageType: "google-storage"
  extraBackendEnvs:
  - name: GOOGLE_STORAGE_BUCKET_NAME
    value: "bucket-name"
  - name: GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64
    valueFrom:
      secretKeyRef:
        name: dify-secret
        key: GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64
```

### Setup vector db

due to the complexity of vector db, this component is not included, you have to use external vector db, likewise , you can inject environment variable to use it

```yaml
global:
  extraBackendEnvs:
  - name: VECTOR_STORE
    value: "milvus"
  - name: MILVUS_HOST
    value: "my-milvus"
```

this is not a complete configuration for vector db, please consult to [dify 文档](https://docs.dify.ai/v/zh-hans/getting-started/install-self-hosted/environments) [document](https://docs.dify.ai/getting-started/install-self-hosted/environments) for more info.

Please consult to dify document if you have difficult to get dify running.
