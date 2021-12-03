# channels

## NOTE
you should create a secret under the deploy namespace named `channels-config`

e.g.:

```yaml
apiVersion: v1
data:
  config.json: <cat config.json| base64>
kind: Secret
metadata:
  name: channels-config
  namespace: <namespace>
type: Opaque
```
