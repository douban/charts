# codecov

This helm chart is based on docker-compose provided by [codecov](https://github.com/codecov/self-hosted)

codecov is distributed with `BUSL` instead of any open source license.

this helm is distributed with `Apache License 2.0`

## install

create your own values file , save as `values.yaml`

```yaml
codecov_host: "codecov.example.com"


codecov_config: |
  # edit your config here

extraEnvs: []

ingress:
  enabled: true
  className: "nginx"

  hosts:
    - host: codecov.example.com
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
helm upgrade codecov douban/codecov -f values.yaml --install --debug
```
## known issues

### must use external minio/s3
I setup minio chart to use , but codecov requires a external available s3 service, it is adviced to use external cloud service instead.

pr are welcomed.
