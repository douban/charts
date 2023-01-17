# Archery Kubernetes Helm 部署文档 

## 最低版本要求

* Kubernetes 1.16+
* Helm 3+

## 新增 douban repo
```
helm repo add douban https://douban.github.io/charts/
helm repo update
```

## 安装 helm chart
```
helm install [RELEASE_NAME] douban/archery
```

参考下方的 [配置详解](#配置详解)

## 删除 helm chart
```
helm uninstall [RELEASE_NAME]
```

## 升级 helm chart
helm chart 中, 只有 yaml 的相关修改, 升级时一般不会有 breaking change, 可以直接升级

但要注意如果升级了镜像版本, 请参照 archery 的 release note 进行升级操作, 如改表, 更改配置等.


## 配置详解
此处的配置详解只会介绍重点配置, 全部配置请直接看 values.yaml , 或者使用 `helm show values douban/archery` 查看values 说明

### 最小配置
```
image:
  tag: v1.9.1 # 指定 archery 版本, archery 版本变动较快, 建议手动指定
ingress:
  enabled: true
  className: nginx
  paths:
    - /
  servicePort: 9123

  hosts:
    - archery.my-domain.com # 指定访问域名, 需提前设置好 nginx ingress
```

## 配置说明
在 helm chart 中有若干层配置, 请按需要设置, 优先级从低到高依次为: 
1. archery 依赖的 redis , mysql 组件的配置, 可以在 values.yaml 中的 redis 和 mysql 下进行配置 (默认使用内置的 mysql 和 redis) , 如果需要, 也可以自己制定 redis 或者 mysql 的连接串, 详见 values 文件
2. archery 容器的环境变量, 可以在 envs 下进行配置, 这里的 envs 和 k8s pod env 完全一致, 你可以自定义, 如:
```
envs:
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: archery
        key: SECRET_KEY
  - name: ENABLE_LDAP
    value: "true"
```
3. 容器内自定义的 local_settins.py, 可以在 configmap 下进行配置, 这里的配置会覆盖 archery 容器内的 local_settings.py, 你可以自定义, 如:
```
configMap:
  enabled: true
  # admin password
  superuser:
    username: admin
    password: archery # 请尽快修改
    email: "archery@example.com"
  data:
    local_settings.py: |-
      # -*- coding: UTF-8 -*-
      # 重新设置某些配置
      SECRET_KEY = "my-secret-key"
```

helm chart 只是提供配置的方法, 你可以根据自己的需求进行配置, 如果配置出现不符合预期的, 首先确认渲染出的 yaml 是否符合预期, 如果 yaml 符合预期, 说明是 archery 的问题, 请前往 archery 项目提交 issue.
