# CBS CSI DRIVER Helm Chart

Helm chart for deploying CLB CSI DRIVER.

# Prerequisites

- Kubernetes v1.14.x+
- kube-apiserver and kubelet need `--allow-privileged=true` (for v1.15.x+, kubelet defaults to set `--allow-privileged` to true. if still set it explicitly, will get error.)
- kubelet configuration：`--feature-gates=VolumeSnapshotDataSource=true`
- apiserver/controller-manager configuration：:  `--feature-gates=VolumeSnapshotDataSource=true`
- scheduler configuration：: `--feature-gates=VolumeSnapshotDataSource=true,VolumeScheduling=true`

You can find more information here: [install-kubernetes](https://github.com/TencentCloud/kubernetes-csi-tencentcloud/blob/master/docs/README_CBS.md#install-kubernetes)

The `values.yaml` file provides four StorageClasses by default. If you need to configure your own StorageClass, please refer to the following documentation: [storageclass-parameters](https://github.com/TencentCloud/kubernetes-csi-tencentcloud/blob/master/docs/README_CBS.md#storageclass-parameters)

## Installation

To install the chart with the release name `my-release`, run:

```sh
helm repo add douban https://douban.github.io/charts/
helm install my-release douban/cbs-csi-driver
```

## Uninstallation

To uninstall the `my-release` deployment:

```sh
helm uninstall my-release
```

## Quick Test

You can quickly test the CSI driver by creating a sample PVC and pod:

1. Create a test manifest:
```bash
cat <<EOF > csi-test.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-test-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: cbs-premium-hourly
---
apiVersion: v1
kind: Pod
metadata:
  name: csi-test-app
spec:
  containers:
    - name: app
      image: busybox
      command: ["/bin/sh", "-c", "while true; do echo \$(date) >> /data/test.log; sleep 5; done"]
      volumeMounts:
      - mountPath: "/data"
        name: csi-volume
  volumes:
    - name: csi-volume
      persistentVolumeClaim:
        claimName: csi-test-pvc
EOF
```

2. Apply the configuration:
```bash
kubectl apply -f csi-test.yaml
```

3. Verify resources:
```bash
kubectl get pvc csi-test-pvc
kubectl get pod csi-test-app
```

4. Check data (wait 30 seconds):
```bash
kubectl exec csi-test-app -- cat /data/test.log
```

5. Clean up:
```bash
kubectl delete -f csi-test.yaml
```
