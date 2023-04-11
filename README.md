# Blockchain node for Kryptokrona
Kryptokrona (XKR) blockchain node packaged in a lightweight Docker image that you can you can easily deploy to a Kubernetes cluster or your docker environment using docker compose.

# What is Kryptokrona?
[Kryptokrona](https://kryptokrona.org) is a decentralized cryptocurrency founded in the Scandinavian region of Europe. Sending and receiving money should not be expensive or slow. Kryptokrona works with open source code that allows you to be involved and improve the communication and money of the future. The source can be found on [Github](https://github.com/kryptokrona/kryptokrona).

## Quick reference
- **Maintained by**: [Jelle Kalf](https://github.com/jrkalf)
- **Supported architectures**: `arm64v8`, `amd64`
- **Supported tags**: `latest`, `v1.1.1`

# What is the difference to Kryptokrona's Docker build?
The Dockerfile here is available for learning and optimisation by others. These Docker images are available [here](https://hub.docker.com/repository/docker/jrkalf/kryptokrona-node/).
These Dockerfiles are trimmed down to the bare minimum of running the blockchain node only. Other items that are normally in the build, like wallets and miners, have been stripped away.

# How to use this image
There are two ways of consuming the images:

0. Prerequisits
1. Kubernetes
2. Docker Compose

## Prerequisits
The Kryptokrona blockchain node needs to exchange data with other nodes. This requires you to expose port 11898 from your external firewall to the Kryptokrona blockchain node. Failure to do so, will result in the node being non-functional.

## Kubernetes

**Step 1:** Clone the GitHub repo:
```
$ git clone https://github.com/jrkalf/kryptokrona-node.git && cd kryptokrona-node
```
In this directory you'll find 4 files you need to run the blockchain node:
- services.yaml
- persistentvolume.yaml
- persistentvolumeclaim.yaml
- deployment.yaml

**Step 2:** Create a *namespace* for our Kryptokrona application (optional but recommended):
```
$ kubectl create ns kryptokrona
```

*If you already run the [xmrig-kryptokrona miner](https://github.com/jrkalf/xmrig-kryptokrona/) in your kubernetes, chances are high you already have a namespace called kryptokrona.*

**Step 3:** Edit the [`deployment.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/deployment.yaml) file. Things you may want to modify include:
- `replicas`: number of desired pods to be running. As I run a 3 worker node Turing Pi cluster, I run 3 replica's
- `image:tag`: to view all available versions, go to the [Tags](https://hub.docker.com/repository/docker/jrkalf/xmrig-kryptokrona/tags) tab of the Docker Hub repo.
- `NODE_ARGS`: These are cli options that will be passed to the kryptokronad at runtime.
- `resources`: set appropriate values for `cpu` and `memory` requests/limits.
- `affinity`: the manifest will schedule only one pod per node, if that's not the desired behavior, remove the `affinity` block.

**Step 4:** Edit the [`services.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/services.yaml) file. Things you may want to modify include:
- `namespace`: This must match the namespace from **step 2**.
- `type`: This type must match the type of exposure you're running. Whether it's a clusterIP or LoadBalancer.

**Step 5:** Edit the [`persistentvolume.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/persistentvolume.yaml) file. Things you may want to modify include:
- `name`: Make sure this matches the `volumeName` in the [`persistentvolumeclaim.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/persistentvolumeclaim.yaml) file.
- `storageClassName`: This must match with the name of your local storage provider. **example: I use nfs-client as name for my nfs-external-subdir-provisioner**
- `nfs`: Adjust your settings accordingly. Hint is in the file.

**Step 6:** [`persistentvolumeclaim.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/persistentvolumeclaim.yaml) file. Things you may want to modify include:
- `volumeName`: Make sure this matches the `name` in the [`persistentvolume.yaml`](https://github.com/jrkalf/kryptokronan-node/blob/main/persistentvolume.yaml) file.
- `storageClassName`: This must match with the name of your local storage provider. **example: I use nfs-client as name for my nfs-external-subdir-provisioner**

**Step 4:** Once you are satisfied with the above manifests, create a *deployment*:
```
$ kubectl apply -f services.yaml \
    -f persistentvolume.yaml \
    -f persistentvolumeclaim.yaml \
    -f deployment.yaml
```
## Docker Compose
Edit the [`docker-compose.yml`](https://github.com/jrkalf/kryptokrona-node/blob/main/docker-compose.yml) manifest as needed and run:
```
$ docker-compose up -d
```

## Logging
This Docker image sends the container logs to the `stdout`. To view the logs, run:

```
$ docker logs kryptokrona
```

For Kubernetes run:
```
$ kubectl logs --follow -n kryptokrona <pod-name> 
```
## Disclaimer
Use at your own discression. This repository is by no means financial advise to mine cryptocurrency. 
This is a project to learn how to build containerised applications.

## License
The Docker image is licensed under the terms of the [MIT License](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/LICENSE). XMRig is licensed under the GNU General Public License v3.0. See its [`LICENSE`](https://github.com/xmrig/xmrig/blob/master/LICENSE) file for details.

## Used works from other repositories
This repo is a based on works of:
- [Kryptokrona](https://kryptokrona.org) / [Kryptokrona Github](https://github.com/kryptokrona/kryptokrona)

## Contact 
- Find me on Kryptokrona's [Hugin Messenger](https://hugin.chat) at addres `SEKReT7odTKSJjXs9BqKAwAEZhW8XuiowdFd4MjTUidc11fur3TpGjPeKKqaCzZdbF3YBf1RfqFowD8WrWAei5grQXb8fXujX7K`.
- Find me on [GitHub](https://github.com/jrkalf/), [Mastodon](https://mastodon.nl/@jelle77) or [Twitter](https://twitter.com/jkalf).
