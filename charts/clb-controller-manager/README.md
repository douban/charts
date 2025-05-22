# CLB Manager Controller Helm Chart

Helm chart for deploying CLB Manager Controller with Tencent Cloud CLB integration.

## Installation

To install the chart with the release name `my-release`, run:

```sh
helm repo add douban https://douban.github.io/charts/
helm install my-release douban/clb-manager-controller
```

## Uninstallation

To uninstall the `my-release` deployment:

```sh
helm uninstall my-release
```

## CLB Configuration Guide

This document provides examples and explanations for configuring the Cloud Load Balancer (CLB) through the CLB Manager Controller.

1. CLB-Specific Annotations

The following annotations are specific to Tencent Cloud CLB integration:

```yaml
annotations:
  # Enable health checks (default: "yes")
  healthCheck: "yes"

  # Custom load balancer name (required)
  loadBalancerName: "my-clb"

  # Subnet ID where CLB will be created (required)
  subnetId: "subnet-xxxxxxxx"

  # CLB type: "open" (public) or "internal" (required)
  loadBalancerType: "internal"

  # Pre-existing VIP (optional)
  vip: "10.0.0.100"

  # Bandwidth limit (optional, default: 10Mbps)
  bandwidth: "20"
```

2. Port Configuration

Configure service ports with optional nodePort assignments:

```yaml
ports:
  http:
    port: 80
    nodePort: 30080  # Optional explicit nodePort
  # Add more port configurations as needed
```

3. Complete Example

Here's a complete example of using a Helm chart to create a LoadBalancer service.

```yaml
service:
  enabled: true
  annotations:
    service.beta.kubernetes.io/cvm-loadbalancer-healthcheck: "yes"
    service.beta.kubernetes.io/cvm-loadbalancer-type: "internal"
    service.beta.kubernetes.io/cvm-loadbalancer-name: internal-lb
    service.beta.kubernetes.io/cvm-loadbalancer-subnet-id: subnet-xxxxxx
  labels:
    app.kubernetes.io/name: internal-lb
    app.kubernetes.io/part-of: ingress-nginx
  enableHttp: true
  enableHttps: true
  ports:
    http: 80
    https: 443
  targetPorts:
    http: http
    https: https
  type: LoadBalancer
  nodePorts:
    http: 32180
    https: 32543
```

4. Important Notes

- Required fields for CLB creation:
  * loadBalancerName
  * subnetId
  * loadBalancerType

- When using existing VIP:
  * Set vip annotation
  * Ensure it matches the pre-configured CLB

- For production environments:
  * Always set explicit bandwidth limits
  * Consider using internal LB type for security
  * Define explicit nodePorts when required by your network policies

5. Verification

After deployment, verify your CLB configuration with:

```sh
kubectl get svc <service-name> -o yaml -n <namespace>
```

Check that all annotations are properly set and the CLB is created in your cloud console.
