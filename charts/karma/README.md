# Karma

Karma is an ASL2 licensed alert dashboard for Prometheus Alertmanager.

## Introduction

This chart deploys karma to your cluster via a Deployment and Service.
Optionally you can also enable ingress.

# Prerequisites

- Kubernetes 1.9+

## Installing the Chart

To install the chart with the release name `my-release`, run:

```bash
$ helm repo add wiremind https://wiremind.github.io/wiremind-helm-charts
$ helm install --name my-release wiremind/karma
```

After a few seconds, you should see service statuses being written to the configured output.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The values.yaml lists the configurable parameters of the karma chart and their default values.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
    stable/karma
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/karma
```

> **Tip**: You will have to define the URL to alertmanager in env-settings in [values.yaml](values.yaml), under key ALERTMANAGER_URI .

### Secure configuration

If you have sensitive information in your Karma config you can wrap it in a Kubernetes Secret and then just point to the name of the Secret.

The structure of the Secret must follow the same pattern defined in `configMap.rawConfig`, here's an example on how to generate this Secret
with your Karma configuration:

```sh
# create a temporary file that contains your Karma configuration
cat > karma.conf <<EOL
alertmanager:
  interval: 60s
  servers:
    - name: prod-alertmanager
      uri: https://sensitive:password@alermanager.prod.example.com
      timeout: 10s
      proxy: true
    - name: client-auth
      uri: https://localhost:9093
      timeout: 10s
      tls:
        ca: /etc/ssl/certs/ca-bundle.crt
        cert: /etc/karma/client.pem
        key: /etc/karma/client.key
annotations:
  default:
    hidden: false
  hidden:
    - help
  visible: []
EOL

# create a Secret from this file with the key `karma.conf`
kubectl create secret generic sensitive-karma-config \
    --from-file=karma.conf=./karma.conf
```

Next, point to the secret in your values file

```yml
# values.yaml
existingSecretConfig:
  enabled: true
  secretName: sensitive-karma-config
```

**NOTE:** you can either use `existingSecretConfig` or `configMap`, it cannot be both.
