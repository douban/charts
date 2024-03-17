# dify

This helm chart is based on docker-compose provided by [dify](https://github.com/dify/self-hosted)

dify is distributed with `BUSL` instead of any open source license.

this helm is distributed with `Apache License 2.0`

## install

create your own values file , save as `values.yaml`

```yaml
dify_host: "dify.example.com"


dify_config: |
  # edit your config here

extraEnvs: []

ingress:
  enabled: true
  className: "nginx"

  hosts:
    - host: dify.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific


postgresql:
  # use external postgresql
  embedded: false
```

```
# install it
helm repo add douban https://douban.github.io/charts/
helm upgrade dify douban/dify -f values.yaml --install --debug
```
## known issues

### must use external minio/s3
I setup minio chart to use , but dify requires a external available s3 service, it is adviced to use external cloud service instead.

pr are welcomed.
