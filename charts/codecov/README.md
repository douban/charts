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

## known issues(pr are welcomed)

### timeseries not enabled
codecov does not support tls connection to timescaledb, while the timescaledb provided in [timescaledb helm chart](https://github.com/timescale/helm-charts/tree/main/charts/timescaledb-single) comes with a default ssl verify and I dont know how to turn it off
