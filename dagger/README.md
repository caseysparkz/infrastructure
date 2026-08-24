# Dagger

I am currently in the process of migrating my CI platform to
[Dagger](https://dagger.io/)

## Developing Dagger Modules

Refer to the [official documentation](https://docs.dagger.io/0.21.4/extending/modules/)

## Running Dagger in Kubernetes

### Prerequisites

* A running Kubernetes cluster with a preconfigured `kubectl` profile.
* [Helm](https://helm.sh/docs/intro/install/)

### Setup

1. Install the Dagger Engine DaemonSet on the Kubernetes cluster.

```sh
helm upgrade                                                                  \
   --install                                                                  \
   --namespace=dagger                                                         \
   --create-namespace                                                         \
   dagger                                                                     \
   oci://registry.dagger.io/dagger-helm
```

1. Wait for the Dagger Engine to become ready.

```sh
kubectl wait                                                                  \
   --for condition=Ready                                                      \
   --timeout=60s pod                                                          \
   --selector=name=dagger-dagger-helm-engine                                  \
   --namespace=dagger
```

1. Get the Dagger Engine pod name.

```sh
DAG_POD="$(kubectl get pod                                                    \
   --selector=name=dagger-dagger-helm-engine                                  \
   --namespace=dagger                                                         \
   --output=jsonpath='{.items[0].metadata.name}'                              \
)"

export DAGGER_ENGINE_POD_NAME
```

1. Set the `_EXPERIMENTAL_DAGGER_RUNNER_HOST` variable.

```sh
export _EXPERIMENTAL_DAGGER_RUNNER_HOST="kube-pod://${DAG_POD}?namespace=dagger"
```

1. Check for install success.

```sh
dagger query <<EOF
{
    container {
        from(address:"alpine") {
            withExec(args: ["uname", "-a"]) { stdout }
        }
    }
}
EOF
```
