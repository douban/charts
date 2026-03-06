# Arnor

Arnor 并不是一个具体的 app, 本 Chart 用于一些简单的项目部署, 使用者在填写了镜像及域名配置后, 即可快速拉起一个 HTTP 应用。

## 使用步骤

1. `helm repo add douban https://douban.github.io/charts/`
2. `helm install my-app douban/arnor -f my-values.yaml`

## 镜像

- `image.repository`: 业务镜像仓库 (如 `registry.example.com/my-app`)
- `image.tag`: 镜像版本号 (如 `v1.0.0`)

## 主机名/域名路由

Arnor 可分别启用 Ingress 或 Envoy Gateway HTTPRoute, 两者互不依赖。

### Ingress 配置

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: app-example-com-tls
      hosts:
        - app.example.com
```

### HTTPRoute 配置

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: envoy-gateway-bundle
      namespace: envoy-gateway-system
  hostnames:
    - app.example.com
  extraPaths: []
```

## 挂载 Volume 与 Secret

1. 在 `volumes` 中定义所需卷 (ConfigMap、Secret、PVC 等)。
2. 在 `volumeMounts` 中将卷挂载到容器路径。

示例:

```yaml
volumes:
	- name: app-config
		configMap:
			name: my-config
	- name: extra-secret
		secret:
			secretName: my-app-secret
volumeMounts:
	- name: app-config
		mountPath: /etc/app
	- name: extra-secret
		mountPath: /var/run/secret
		readOnly: true
```

## Vault 静态密钥注入

启用 `vaultStaticSecret.enabled` 后, Chart 会负责拉取 Vault 中的静态密钥并注入到 Kubernetes Secret 中; 需要在 `volumes` 与 `volumeMounts` 手动引用该 Secret 才能在容器内使用。

如果没有设置 `vaultStaticSecret.secretNameOverride`, secret 名字会与 fullname 完全相同, 也就是:

```bash
# release name 和 chart 同名时, 为 release name
arnor
# release name 和 chart 不同时, 为 release name - chart name
my-app-arnor
# 填写了 fullnameOverride 的情况下, 以 fullnameOverride 为准
my-fullname
# 详细逻辑请参考 _helpers.tpl 内的代码
```

```yaml
vaultStaticSecret:
  enabled: true
  mount: kv-v2
  path: secret/data
  secretNameOverride: my-secret

volumes:
  - name: vault-secret
    secret:
      secretName: my-secret
volumeMounts:
  - name: vault-secret
    mountPath: /vault/secrets
    readOnly: true
```

> 最终路径与 `path` 完全一致, 请确认 Vault 中已存在该路径。

## 完整示例

```yaml
image:
  repository: registry.example.com/frontend
  tag: v1.2.3

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: frontend.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific

httpRoute:
  enabled: false

volumes:
  - name: env-secret
    secret:
      secretName: frontend-env
  - name: vault-secret
    secret:
      secretName: frontend
volumeMounts:
  - name: env-secret
    mountPath: /app/.env
    readOnly: true
  - name: vault-secret
    mountPath: /vault/data
    readOnly: true

vaultStaticSecret:
  enabled: true
  secretNameOverride: frontend
```

